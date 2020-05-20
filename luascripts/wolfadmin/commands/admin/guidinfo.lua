
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit
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

function commandListPlayerByGUID(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9player history is disabled.\";")

        return true
    elseif victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dguidinfo usage: !guidinfo [GUID] [offset/page]\";")

        return true
    else
        cmdClient = victim
    end
 
	playerGUID = db.getPlayer(victim)
	
	if not (playerGUID) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dguidinfo: ^9there is no history for selected player GUID ^7"..victim.."^9.\";")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dDetails for GUID: ^7"..victim.."^d:\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPlayer DB ID: ^1"..string.format("%4s", playerGUID["id"]).."^9 (this number you will need for offline BAN and so)\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPlayer level: ^7"..string.format("%4s", playerGUID["level_id"]).."\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dIP: ^7"..playerGUID["ip"].."\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSeen ^7"..playerGUID["seen"].."^d times\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLast seen: ^7"..os.date("%d/%m/%Y", playerGUID["lastseen"]).."\";")

		local player = playerGUID["id"]
		local count = db.getAliasesCount(player)
		local limit, offset = pagination.calculate(count, 30, tonumber(offset))
		local aliases = db.getAliases(player, limit, offset)
		
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases: \";")
		for _, alias in pairs(aliases) do
			local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
			local spaces = string.rep(" ", numberOfSpaces)
			
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
		end
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing aliases results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dguidinfo: ^9history for GUID ^7"..victim.." ^9was printed to the console.\";")
    end

    return true
end
commands.addadmin("guidinfo", commandListPlayerByGUID, auth.PERM_SEARCHPLAYER, "display history for a specific player", "^9[^3GUID^9] ^9(^hoffset^9)", (settings.get("g_playerHistory") == 0))
