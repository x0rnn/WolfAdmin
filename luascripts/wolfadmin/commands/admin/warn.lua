
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

local history = require (wolfa_getLuaPath()..".admin.history")

local db = require (wolfa_getLuaPath()..".db.db")

local commands = require (wolfa_getLuaPath()..".commands.commands")

local players = require (wolfa_getLuaPath()..".players.players")

local settings = require (wolfa_getLuaPath()..".util.settings")

local stats = require (wolfa_getLuaPath()..".players.stats")

local admin = require (wolfa_getLuaPath()..".admin.admin")

function commandWarn(clientId, command, victim, ...)
    local cmdClient

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        return false
    elseif not victim or not ... then
        return false
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        return false
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        return false
    end

    history.add(cmdClient, clientId, os.time(), "warn", table.concat({...}, " "))

    return false
end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", true, (settings.get("g_standalone") ~= 0 or settings.get("g_playerHistory") == 0))

function commandWarn(clientId, command, victim, ...)
    local cmdClient

    if not victim or not ... then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn usage: "..commands.getadmin("warn")["syntax"].."\";")

        return true
    elseif tonumber(victim) == nil or tonumber(victim) < 0 or tonumber(victim) > tonumber(et.trap_Cvar_Get("sv_maxclients")) then
        cmdClient = et.ClientNumberFromString(victim)
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9no or multiple matches for '^7"..victim.."^9'.\";")

        return true
    elseif not et.gentity_get(cmdClient, "pers.netname") then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9no connected player by that name or slot #\";")

        return true
    end

    if auth.getPlayerLevel(cmdClient) > auth.getPlayerLevel(clientId) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dwarn: ^9sorry, but your intended victim has a higher admin level than you do.\";")

        return true
    end

    local reason = table.concat({...}, " ")

    if settings.get("g_playerHistory") ~= 0 then
        history.add(cmdClient, clientId, "warn", reason)
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ccp "..cmdClient.." \"^7You have been warned by "..players.getName(clientId)..": ^7"..reason..".\";")
--    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dwarn: ^7"..players.getName(cmdClient).." ^9has been warned.\";")

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/misc/referee.wav\";")

	local warncount 
	local maxwarns
	local warnremains

	maxwarns = 4

	if tonumber(stats.get(cmdClient, "warncount")) == nil or tonumber(stats.get(cmdClient, "warncount")) == 0 then
		warncount = 1
	else
		warncount = tonumber(stats.get(cmdClient, "warncount"))
	end
			
	if warncount == maxwarns then
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^1Player auto-kicked: ^7"..players.getName(cmdClient).." ^1because of several warnings...\";")
		admin.kickPlayer(cmdClient, clientId, reason)
		if settings.get("g_playerHistory") ~= 0 then
			history.add(cmdClient, clientId, "auto-kick", reason)
		end
		return true
	end
	
	warnremains = 0
	warnremains = maxwarns - warncount
	
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dwarn: ^7"..players.getName(cmdClient).." ^9has been warned and "..warnremains.." warning(s) remaining to auto-kick \";")
	warncount = warncount + 1
	stats.set(cmdClient, "warncount", warncount)


end
commands.addadmin("warn", commandWarn, auth.PERM_WARN, "warns a player by displaying the reason", "^9[^3name|slot#^9] ^9[^3reason^9]", nil, (settings.get("g_standalone") == 0))
