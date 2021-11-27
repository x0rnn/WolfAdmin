
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local db = wolfa_requireModule("db.db")
local players = wolfa_requireModule("players.players")
local bits = wolfa_requireModule("util.bits")
local events = wolfa_requireModule("util.events")
local settings = wolfa_requireModule("util.settings")
local timers = wolfa_requireModule("util.timers")
local constants = wolfa_requireModule("util.constants")
local util = wolfa_requireModule("util.util")
local stats = wolfa_requireModule("players.stats")

local clantagprotectTimer
local clantagprotect = {}

function clantagprotect.check()
	
	local playersOnline = {}
	for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isConnected(playerId) then
            table.insert(playersOnline, playerId)
        end
    end

    for _, player in pairs(playersOnline) do
		local TagToProtect = et.trap_Cvar_Get("g_clantagprotect")
		local TagProtectOn
		if (TagToProtect == nil) then
			TagToProtect = ""
			TagProtectOn = 0
		else
			TagProtectOn = 1
		end 
		
		local PlayerNickname = et.gentity_get(player, "pers.netname")
		local PlayerCleanNickname = util.removeColors(PlayerNickname)
		
		local TagProtectLevel = et.trap_Cvar_Get("g_clantagprotectlevel")
		if tonumber(TagProtectLevel) == nil or tonumber(TagProtectLevel) == 0 then
			TagProtectLevel = 0
		end 
		
		if ((TagProtectOn == 1) and (string.len(TagToProtect) >= 1)) then

			if (string.find(PlayerCleanNickname, TagToProtect) ~= nil) then

				if (tonumber(auth.getPlayerLevel(player)) <= tonumber(TagProtectLevel)) then 
					if tonumber(stats.get(player, "warncount")) == nil or tonumber(stats.get(player, "warncount")) == 0 then
						warncount = 1
					else
						warncount = tonumber(stats.get(player, "warncount"))
					end
					
					if settings.get("g_playerHistory") ~= 0 then
						db.addHistory(db.getPlayerId(player), 1, "warn", os.time(), "ClanTagProtection: Player nickname: "..PlayerCleanNickname)
					end

					-- warn player
					et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..player.." \"^1Tag ^3"..TagToProtect.." ^1is protected to members only! Change your nickname ASAP or kick will follow!\";")
					et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^1 ClanTagProtection: ^9Player ^7"..PlayerCleanNickname.." ^9is ^1NOT ^9allowed to use protected Clan tag! \";")
					et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/misc/referee.wav\";")
					
					et.G_Print("ClanTagProtection: TagProtectLevel "..TagProtectLevel.."\n")
					et.G_Print("ClanTagProtection: TagToProtect "..TagToProtect.."\n")
					et.G_Print("ClanTagProtection: PlayerCleanNickname "..PlayerCleanNickname.."\n")
					et.G_Print("ClanTagProtection: Level_ID "..auth.getPlayerLevel(player).."\n")	
					et.G_Print("ClanTagProtection: PlayerDBID "..db.getPlayerId(player).."\n")	
					
					maxwarns = 4
					warncount = warncount + 1
					stats.set(player, "warncount", warncount)
					
					if warncount >= maxwarns then
					et.G_Print("ClanTagProtection: Max warn count reached. Player kicked. "..PlayerCleanNickname.."\n")
						-- ban player after maxwarns count reached
						warncount = 0
						stats.set(player, "warncount", warncount)
						ban_desc = "You have been kicked, Reason: "..(reason and reason or "kicked by admin")
						db.addBan(db.getPlayerId(player), 1, os.time(), 1, ban_desc)
						et.trap_DropClient(player, "You have been banned, because "..TagToProtect.." is protected Clan tag and you aren't allowed to wear this tag.", 0)
						return true
					end
				end
			end
		end
	end
	playersOnline = nil
	player = nil
	
end
	
function clantagprotect.onGameInit(levelTime, randomSeed, restartMap)
    clantagprotectTimer = timers.add(clantagprotect.check, 30000, 0)
end
events.handle("onGameInit", clantagprotect.onGameInit)