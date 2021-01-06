
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit
-- extended by EAGLE_CZ, www.teammuppet.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- at your option any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local db = wolfa_requireModule("db.db")

local players = wolfa_requireModule("players.players")

local events = wolfa_requireModule("util.events")
local settings = wolfa_requireModule("util.settings")
local util = wolfa_requireModule("util.util")

local admin = {}

local playerRenames = {}

function admin.putPlayer(clientId, teamId)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "forceteam "..clientId.." "..util.getTeamCode(teamId)..";")
end

function admin.kickPlayer(victimId, invokerId, reason)

	if tonumber(et.trap_Cvar_Get("g_autoTempBanTime")) then
			TempBanTime = tonumber(et.trap_Cvar_Get("g_autoTempBanTime"))
	else
			-- time in seconds 
			TempBanTime = 900
	end

    local victimPlayerId = db.getPlayer(players.getGUID(victimId))["id"]
    local invokerPlayerId = db.getPlayer(players.getGUID(invokerId))["id"]

	ban_desc = "You have been kicked, Reason: "..(reason and reason or "kicked by admin")
    db.addBan(victimPlayerId, invokerPlayerId, os.time(), TempBanTime, ban_desc)

    et.trap_DropClient(victimId, "You have been kicked, Reason: "..(reason and reason or "kicked by admin"), 0)
	
end

function admin.kickPlayerServerFull(victimId, invokerId)
	
	if tonumber(et.trap_Cvar_Get("g_AllowedToComeBack")) then
			AllowedToComeBack = tonumber(et.trap_Cvar_Get("g_AllowedToComeBack"))
	else
			-- time in seconds 
			AllowedToComeBack = 5
	end

    local victimPlayerId = db.getPlayer(players.getGUID(victimId))["id"]
    local invokerPlayerId = db.getPlayer(players.getGUID(invokerId))["id"]

	ban_desc = "You have been kicked, because server was full. Please try one of our other server or come back later."
    db.addBan(victimPlayerId, invokerPlayerId, os.time(), AllowedToComeBack, ban_desc)

    et.trap_DropClient(victimId, "You have been kicked, because server was full. Please try one of our other server or come back later.", 0)
	
end

function admin.setPlayerLevel(clientId, level)
    local playerId = db.getPlayer(players.getGUID(clientId))["id"]

    db.updatePlayerLevel(playerId, level)
end

function admin.onClientConnectAttempt(clientId, firstTime, isBot)
    if firstTime and db.isConnected() then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")

        if string.len(guid) < 32 then
            return "\n\nIt appears you do not have a ^7GUID^9/^7etkey^9. In order to play on this server, create an ^7etkey^9.\n\nMore info: ^7www.etkey.org"
        end

        if settings.get("g_standalone") ~= 0 then
            local player = db.getPlayer(guid)
            if player then
                local playerId = player["id"]
                local ban = db.getBanByPlayer(playerId)
                if ban then
                    return "\n\nYou have been banned for "..ban["duration"].." seconds, Reason: "..ban["reason"]
                end

			-- IP bans
				local ip = string.gsub(et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "ip"), ":%d*", "")
				local name = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "name")
				local IPban = db.getBanByIP(ip)

				if IPban then
					local BannedId = IPban["victim_id"]
					local banned = db.getBanByPlayer(BannedId)

					if banned then
						db.addHistory(BannedId, 1, "LOG", os.time(), "Banned IP: "..ip.." tried to connect with a different nickname: "..name)
						return "\n\nYou have been banned for "..banned["duration"].." seconds, Reason: "..banned["reason"]
					end
				end
			-- IP bans end

            end
        end
    end

    events.trigger("onClientConnect", clientId, firstTime, isBot)
end
events.handle("onClientConnectAttempt", admin.onClientConnectAttempt)

function admin.onClientConnect(clientId, firstTime, isBot)
    if settings.get("g_standalone") ~= 0 and db.isConnected() then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientId), "cl_guid")
        local player = db.getPlayer(guid)

        if player then
            local playerId = player["id"]
            local mute = db.getMuteByPlayer(playerId)

            if mute then
                players.setMuted(clientId, true, mute["type"], mute["issued"], mute["expires"])
            end
        end
    end
end
events.handle("onClientConnect", admin.onClientConnect)

function admin.onClientDisconnect(clientId)
    if playerRenames[clientId] then
        playerRenames[clientId] = nil
    end
end
events.handle("onClientDisconnect", admin.onClientDisconnect)

function admin.onClientNameChange(clientId, oldName, newName)
    -- rename filter
    if not playerRenames[clientId] or playerRenames[clientId]["last"] < os.time() - 60 then
        playerRenames[clientId] = {
            ["first"] = os.time(),
            ["last"] = os.time(),
            ["count"] = 1
        }
    else
        playerRenames[clientId]["count"] = playerRenames[clientId]["count"] + 1
        playerRenames[clientId]["last"] = os.time()

        -- give them some time
        if (playerRenames[clientId]["last"] - playerRenames[clientId]["first"]) > 3 then
            local renamesPerMinute = playerRenames[clientId]["count"] / (playerRenames[clientId]["last"] - playerRenames[clientId]["first"]) * 60

            if renamesPerMinute > settings.get("g_renameLimit") then
                admin.kickPlayer(clientId, -1337, "Too many name changes.")
            end
        end
    end

    -- on some mods, this message is already printed
    -- known: old NQ versions, Legacy
    if et.trap_Cvar_Get("fs_game") ~= "legacy" then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay -1 \""..oldName.." ^7is now known as "..newName.."\";")
    end

    -- update database
    if db.isConnected() then
        local playerId = db.getPlayer(players.getGUID(clientId))["id"]
        local alias = db.getAliasByName(playerId, newName)

        if alias then
            db.updateAlias(alias["id"], os.time())
        else
            db.addAlias(playerId, newName, os.time())
        end
    end
end
events.handle("onClientNameChange", admin.onClientNameChange)

return admin
