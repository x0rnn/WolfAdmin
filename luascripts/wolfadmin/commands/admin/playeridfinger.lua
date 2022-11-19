
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
local history = wolfa_requireModule("admin.history")
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")
local util = wolfa_requireModule("util.util")
local pagination = wolfa_requireModule("util.pagination")
local settings = wolfa_requireModule("util.settings")

function commandPlayerIDFinger(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9player history is disabled.\";")
        return true

    elseif victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dplayeridfinger usage: !playeridfinger [DB Player ID] [offset/page]\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
        return true

    else
        cmdClient = victim
    end
 
	playerDBID = db.getPlayerByID(victim)
	
	if not (playerDBID) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dplayeridfinger: ^9there is no history for selected player ID ^7"..victim.."^9.\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
		return true
 
	else
		
		local player = playerDBID["id"]
		
		local name = db.getLastAlias(player)["alias"]
		local cleanname = db.getLastAlias(player)["cleanalias"]
		local codedname = name:gsub("%^([^^])", "^^2%1")
		local level = playerDBID["level_id"]
		local levelName = util.removeColors(auth.getLevelName(level))
		local guid = playerDBID["guid"]
		local seen = playerDBID["seen"]
		local lastseen = playerDBID["lastseen"]
		local ip = playerDBID["ip"]

		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dInformation about ^7"..name.."^d:\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dName:    ^2"..util.removeColors(cleanname).." ("..victim..")\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLevel:   ^2"..level.." ("..levelName..")\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dGUID:    ^2"..guid.."\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dIP:      ^2"..ip.."\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSeen:      ^2"..seen.."\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLast seen: ^7"..os.date("%d/%m/%Y", playerDBID["lastseen"]).."\";")
	
		local count = db.getAliasesCount(player)
		local limit, offset = pagination.calculate(count, 30, tonumber(offset))
		local aliases = db.getAliases(player, limit, offset)
		
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAliases for ^7"..name.."^d:\";")
		for _, alias in pairs(aliases) do
			local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
			local spaces = string.rep(" ", numberOfSpaces)
			
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^7"..spaces..alias["alias"].." ^7"..string.format("%8s", alias["used"]).." times\";")
		end
		
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing results ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dplayeridfinger: ^9history for Player ID ^1"..victim.." ^9was printed to the console.\";")

    end


    return true
end
commands.addadmin("playeridfinger", commandPlayerIDFinger, auth.PERM_SEARCHPLAYER, "display history for a specific player", "^9[^3DB Player ID^9] ^9(^hoffset^9)", (settings.get("g_playerHistory") == 0))
