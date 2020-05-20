
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

local players = wolfa_requireModule("players.players")
local db = wolfa_requireModule("db.db")
local pagination = wolfa_requireModule("util.pagination")
local settings = wolfa_requireModule("util.settings")
local util = wolfa_requireModule("util.util")

function commandFinger(clientId, command, victim)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dfinger usage: "..commands.getadmin("finger")["syntax"].."\";")

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

    local name = players.getName(cmdClient)
    local cleanname = util.removeColors(players.getName(cmdClient))
    local codedname = players.getName(cmdClient):gsub("%^([^^])", "^^2%1")
    local slot = cmdClient
    local level = auth.getPlayerLevel(cmdClient)
    local levelName = util.removeColors(auth.getLevelName(level))
    local guid = players.getGUID(cmdClient)
    local ip = players.getIP(cmdClient)
    local version = players.getVersion(cmdClient)

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dInformation about ^7"..name.."^d:\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dName:    ^2"..cleanname.." ("..codedname..")\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSlot:    ^2"..slot..(slot < tonumber(et.trap_Cvar_Get("sv_privateClients")) and " ^9(private)" or "").."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLevel:   ^2"..level.." ("..levelName..")\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dGUID:    ^2"..guid.."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dIP:      ^2"..ip.."\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dVersion: ^2"..version.."\";")


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
commands.addadmin("finger", commandFinger, auth.PERM_FINGER, "gives specific information about a player", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))
