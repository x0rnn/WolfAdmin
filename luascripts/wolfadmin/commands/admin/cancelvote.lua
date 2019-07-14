
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

local commands = require (wolfa_getLuaPath()..".commands.commands")
local auth = require (wolfa_getLuaPath()..".auth.auth")

function commandCancelVote(clientId, command)
	
	et.trap_SendConsoleCommand( et.EXEC_APPEND, "vote_percent \"99\"\n" )
	
	--et.CS_VOTE_NO
	et.trap_SetConfigstring(9, "30")

	--et.CS_VOTE_TIME
	et.trap_SetConfigstring(6 , "") 
	
	et.trap_SendConsoleCommand( et.EXEC_APPEND, "vote_percent \"50\"\n" )
	et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat -1 \"^1Vote was canceled by admin!\";")

    return true
end
commands.addadmin("cancelvote", commandCancelVote, auth.PERM_CANCELVOTE, "Cancel vote in progress...")
