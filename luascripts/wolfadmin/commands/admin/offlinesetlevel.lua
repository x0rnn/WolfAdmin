
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

local admin = wolfa_requireModule("admin.admin")
local commands = wolfa_requireModule("commands.commands")
local settings = wolfa_requireModule("util.settings")
local auth = wolfa_requireModule("auth.auth")
local history = wolfa_requireModule("admin.history")
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")
local util = wolfa_requireModule("util.util")
local pagination = wolfa_requireModule("util.pagination")
local settings = wolfa_requireModule("util.settings")


function commandOffLineSetLevel(clientId, command, victim, level)
	
	local cmdClient
	local playerDBID
	
	level = tonumber(level) or 0
	
	if victim == nil or level == 0 then
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel ^1Warning! DB Player ID or level can't be empty or zero!\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel usage: ^1!offlinesetlevel [DB Player ID] [level]\";")
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
		return false
	end
	
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddebug: ^9clientId ^7"..clientId.."^9.\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddebug: ^9command ^7"..command.."^9.\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddebug: ^9victim ^7"..victim.."^9.\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^ddebug: ^9level ^7"..level.."^9.\";")
	
		
    cmdClient = victim
    playerDBID = db.getPlayerByID(victim)
	
	local victimcurrentlevel = playerDBID["level_id"]
	local victimlevelName = util.removeColors(auth.getLevelName(victimcurrentlevel))
	local player = playerDBID["id"]
	local name = db.getLastAlias(player)["alias"]	
	local cleanname = db.getLastAlias(player)["cleanalias"]
	local oldlevel = playerDBID["level_id"]
	local oldlevelName = util.removeColors(auth.getLevelName(oldlevel))
	local newlevelName = util.removeColors(auth.getLevelName(level))
	local guid = playerDBID["guid"]
	local lastseen = playerDBID["lastseen"]
	local ip = playerDBID["ip"]
	local invoker = db.getPlayerId(clientId)
	
	if not (playerDBID) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel: ^1Cannot find a player by DB Player ID ^7"..victim.."^9.\";")
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dTip: if you dont know, how to get DB Player ID, try command ^1!searchplayer [nickname]\";")
		return false
	else
		if victimcurrentlevel > auth.getPlayerLevel(clientId) then
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel: ^9sorry, but your intended victim has a higher admin level than you do.\";")

			return true
		elseif not db.getLevel(level) then
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel: ^9this admin level does not exist.\";")

			return true
		elseif level > auth.getPlayerLevel(clientId) then
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dofflinesetlevel: ^9you may not setlevel higher than your current level.\";")

			return true
		end
	end

	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSetting level to: ^7"..name.."^d:\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPlayer name:    ^3"..util.removeColors(cleanname).." (Player DB ID: "..victim..")\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dGUID:    ^3"..guid.."\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dLast seen: ^3"..os.date("%d/%m/%Y", playerDBID["lastseen"]).."\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d--------------------------------------------------------------\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dCurrent Level:   ^2"..oldlevel.." ("..oldlevelName..")\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dNew Level:   ^1"..level.." ("..newlevelName..")\";")
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^d--------------------------------------------------------------\";")
	
    db.addHistory(player, invoker, "offlinesetlevel", os.time(), "from lvl: "..oldlevel.." to lvl: "..level.."")
	db.updatePlayerLevel(player, level)
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^dofflinesetlevel: ^7"..name.." ^9is now a level ^7"..level.." ^9player.\";")

    return true
end
commands.addadmin("offlinesetlevel", commandOffLineSetLevel, auth.PERM_SETLEVEL, "sets the admin level of a player when is offline by DB Player ID", "^9[^3DB Player ID^9] ^9[^3level^9]", nil, (settings.get("g_standalone") == 0))
