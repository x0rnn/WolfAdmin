
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

local game = wolfa_requireModule("game.game")

local admin = wolfa_requireModule("admin.admin")

local util = wolfa_requireModule("util.util")
local constants = wolfa_requireModule("util.constants")
local settings = wolfa_requireModule("util.settings")

function commandBeer(clientId, command, victim)

    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbeer usage: "..commands.getadmin("kick")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbeer: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbeer: ^9no connected player by that name or slot #\";")

        return true
    end 

    local fileDescriptor, fileLength = et.trap_FS_FOpenFile("sound/world/steam_03.wav", et.FS_READ)

    if fileLength == -1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dbeer: ^9 sound file sound/world/steam_03.wav does not exist.\";")

        return 0
    end

    et.trap_FS_FCloseFile(fileDescriptor)
	
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^7 TeamMuppet Pub: "..et.gentity_get(clientId, "pers.netname").."^7 buyed a can of beer to "..et.gentity_get(cmdClient, "pers.netname").." ^7Cheers!\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/world/steam_03.wav\";")

    return true
end
commands.addadmin("beer", commandBeer, auth.PERM_BEER, "Buy a can of beer to selected player", "^9[^3name|slot#^9]", nil, (settings.get("g_standalone") == 0))