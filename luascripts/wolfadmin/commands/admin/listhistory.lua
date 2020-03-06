
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2019 Timo 'Timothy' Smit
-- and extended by EAGLE_CZ, www.teammuppet.com

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
local history = wolfa_requireModule("admin.history")
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")
local util = wolfa_requireModule("util.util")
local pagination = wolfa_requireModule("util.pagination")
local settings = wolfa_requireModule("util.settings")

function commandListHistory(command, offset)

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlisthistory: ^9player history is disabled.\";")
        return true
    end
	
	local listFromHistory = db.listHistory(offset)
			
	if not (listFromHistory) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dlisthistory: ^9there is no history in the table^9.\";")
		return true
 
	else

		local count = db.getHistoryTotalCount()
		local offset = pagination.calculate(count, 30, tonumber(offset))
		
		if (listFromHistory and #listFromHistory > 0) then
		
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dHistory for ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(playerHistory[1]["victim_id"])["alias"])).."^7^d:\";")
			for _, history in pairs(listFromHistory) do
					et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f Event ID: ^7"..string.format("%4s", history["id"]).."^f By: ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(history["invoker_id"])["alias"])).." ^f Date: ^7"..os.date("%d/%m/%Y", history["datetime"]).."^f Action: ^7"..string.format("%-8s", history["type"].." ").."^f Reason or parameters: ^7"..history["reason"].."\";")
			end
		
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + 30).." ^9of ^7"..count.."^9.\";")
		
		end
		
--		    local count = db.getHistoryCount(victim)
--			local limit, offset = pagination.calculate(count, 30, tonumber(offset))
--			local playerHistory = db.getHistory(victim, limit, offset)

--			if not (playerHistory and #playerHistory > 0) then
--				et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dplayeridhistory: ^9there is no history for selected player ID ^7"..victim.."^9.\";")
--				et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
--				return true
--			else
--				et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dHistory for ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(playerHistory[1]["victim_id"])["alias"])).."^7^d:\";")
--				for _, history in pairs(playerHistory) do
--					et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^f Event ID: ^7"..string.format("%4s", history["id"]).."^f By: ^7"..string.format("%-20s", util.removeColors(db.getLastAlias(history["invoker_id"])["alias"])).." ^f Date: ^7"..os.date("%d/%m/%Y", history["datetime"]).."^f Action: ^7"..string.format("%-8s", history["type"].." ").."^f Reason or parameters: ^7"..history["reason"].."\";")
--				end

--				et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
--			end



		et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dlisthistory: ^9history was printed to the console.\";")
    end

    return true
end
commands.addadmin("listhistory", commandListHistory, auth.PERM_SEARCHPLAYER, "display history table", " ^9(^hoffset^9)", (settings.get("g_playerHistory") == 0))
