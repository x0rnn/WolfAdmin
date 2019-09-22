
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
local admin = require (wolfa_getLuaPath()..".admin.admin")

local commands = require (wolfa_getLuaPath()..".commands.commands")
local db = require (wolfa_getLuaPath()..".db.db")

local history = require (wolfa_getLuaPath()..".admin.history")

local players = require (wolfa_getLuaPath()..".players.players")

local constants = require (wolfa_getLuaPath()..".util.constants")
local settings = require (wolfa_getLuaPath()..".util.settings")
local util = require (wolfa_getLuaPath()..".util.util")

function commandRename(clientId, command, victim, newNickName)
    local cmdClient

    if victim == nil or newNickName == nill then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename usage: "..commands.getadmin("rename")["syntax"].."\";")

        return true
    
	elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.isPlayerAllowed(cmdClient, "!") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^7"..et.gentity_get(cmdClient, "pers.netname").." ^9is immune to this command.\";")

        return true
    elseif auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9sorry, but your intended victim has a higher admin level than you do.\";")

    end

    local oldNickName = et.gentity_get(cmdClient, "pers.netname")
		
		local name = et.gentity_get(cmdClient,"pers.netname")
		local userinfo = et.trap_GetUserinfo(cmdClient)
		
		userinfo = et.Info_SetValueForKey(userinfo, "name", newNickName)
		et.trap_SetUserinfo(cmdClient, userinfo)
		et.ClientUserinfoChanged(cmdClient)	
	
	
    if settings.get("g_playerHistory") ~= 0 then
		reason = "from: "..util.removeColors(oldNickName).." to: "..util.removeColors(newNickName)
        history.add(cmdClient, clientId, "rename", reason)
    end

	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^drename: ^9Player ^7"..oldNickName.."^9 was renamed to "..newNickName.." \";")
    --et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^drename: ^7"..players.getName(oldNickName).." ^9was renamed by admin.\";")

    return true
end
commands.addadmin("rename", commandRename, auth.PERM_RENAME, "rename a player", "^9[^3name|slot#^9] ^9[^3newname^9]", nil, (settings.get("g_standalone") == 0))
