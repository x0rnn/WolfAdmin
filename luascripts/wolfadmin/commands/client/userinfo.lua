
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit

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

local auth = require (wolfa_getLuaPath()..".auth.auth")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

local db = require (wolfa_getLuaPath()..".db.db")
local pagination = require (wolfa_getLuaPath()..".util.pagination")
local util = require (wolfa_getLuaPath()..".util.util")

function commandUserInfo(clientId, command, victim)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger usage: /ui [name]/[slotID] \";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger: ^9no connected player by that name or slot #\";")

        return true
    end

    local stats = {
        ["name"] = players.getName(cmdClient),
        ["cleanname"] = players.getName(cmdClient):gsub("%^[^^]", ""),
        ["codedsname"] = players.getName(cmdClient):gsub("%^([^^])", "^^2%1"),
        ["slot"] = cmdClient,
        ["guid"] = players.getGUID(cmdClient),
        ["ip"] = players.getIP(cmdClient),
        ["version"] = players.getVersion(cmdClient)
    }

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dInformation about ^7"..stats["name"].."^d:\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dName:    ^2"..stats["cleanname"].." ("..stats["codedsname"]..")\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSlot:    ^2"..stats["slot"]..(stats["slot"] < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or "").."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dGUID:    ^2"..stats["guid"].."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dIP:      ^2"..stats["ip"].."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dVersion: ^2"..stats["version"].."\";")

if not db.isConnected() then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlistaliases: ^9alias history is disabled.\";")   
    return true
	end

	local player = db.getPlayer(players.getGUID(cmdClient))["id"]
    
    local count = db.getAliasesCount(player)
    local limit, offset = pagination.calculate(count, 30, tonumber(offset))
    local aliases = db.getAliases(player, limit, offset)
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases for ^7"..et.gentity_get(cmdClient, "pers.netname").."^d:\";")
    for _, alias in pairs(aliases) do
        local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
        local spaces = string.rep(" ", numberOfSpaces)
        
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
    end
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlistaliases: ^9aliases for ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9were printed to the console.\";")

    return true
end
-- commands.addclient("UserInfo", commandUserInfo, auth.PERM_UserInfo, "[^2message^7]", true)
-- commands.addclient("ui", commandUserInfo, auth.PERM_UserInfo, "[^2message^7]", true)

commands.addclient("finger", commandUserInfo, auth.PERM_FINGER, "gives specific information about a player", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))
commands.addclient("ui", commandUserInfo, auth.PERM_FINGER, "gives specific information about a player", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))