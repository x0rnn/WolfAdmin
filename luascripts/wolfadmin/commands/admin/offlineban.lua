
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
local bans = wolfa_requireModule("admin.bans")
local history = wolfa_requireModule("admin.history")
local commands = wolfa_requireModule("commands.commands")
local util = wolfa_requireModule("util.util")
local settings = wolfa_requireModule("util.settings")
local db = wolfa_requireModule("db.db")
local pagination = wolfa_requireModule("util.pagination")

function commandOfflineBan(clientId, command, victim, ...)
    local cmdClient

    if victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflineban usage: "..commands.getadmin("offlineban")["syntax"].."\";")
        return true
    else
        cmdClient = tonumber(victim)
    end

    if cmdClient == -1 or cmdClient == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dban: ^9no or multiple matches for '^7"..victim.."^9'.\";")
        return true
    end

	-- sqlite3.addBan(victimId, invokerId, issued, duration, reason)

    local args = {...}
    local duration, reason

    if args[1] and util.getTimeFromString(args[1]) and args[2] then
        duration = util.getTimeFromString(args[1])
        reason = table.concat(args, " ", 2)
    elseif args[1] and util.getTimeFromString(args[1]) then
        duration = util.getTimeFromString(args[1])
        reason = "Banned by admin. Appeal at www.teammuppet.com"
    elseif args[1] then
        duration = util.getTimeFromString("1y")
        reason = table.concat(args, " ")
    
    end
	
	invokerId = db.getPlayerId(clientId)
	invokerName = db.getAliases(invokerId, 1, 0)
	victimName = db.getAliases(victim, 1, 0)

	if not (victimName) then
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflineban: ^9Cannot find DB Player ID ^1"..victim.."^d in the database!.\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
	return true
	
	else 
		if tonumber(duration) == nil then
			duration = util.getTimeFromString("1y")
		end

		invokerName = db.getAliases(invokerId, 1, 0)
		victimName = db.getAliases(victim, 1, 0)
		
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Adding Off-line BAN in to the database: \";")	
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d --------------------------------------------------- \";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Banned Nickname: "..victimName[1]["alias"].." \";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Duration (in seconds) : ^1"..duration.." \";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Reason: ^1"..reason.." \";")	
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Banned by: ^1"..invokerName[1]["alias"].." \";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d --------------------------------------------------- \";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d Ban was sucessfully added...\";")		
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9 Tip: Now you can list bans with ^1!showbans ^d command or lift the ban with ^1!unban [BanID]\";")		

		db.addBan(victim, invokerId, os.time(), duration, reason)

		if settings.get("g_playerHistory") ~= 0 then
			db.addHistory(victim, invokerId, "ban", os.time(), reason)
		end
		
	end
	
    return true
end
commands.addadmin("offlineban", commandOfflineBan, auth.PERM_BAN, "ban a player which is currently OFFLINE with an optional duration and reason", "^9[^3Player DB ID^9] ^9(^3duration^9) ^9(^3reason^9)", (settings.get("g_standalone") == 0))
