
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2018 Timo 'Timothy' Smit

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

local util = require "luascripts.wolfadmin.util.util"
local constants = require "luascripts.wolfadmin.util.constants"
local commands = require "luascripts.wolfadmin.commands.commands"
local admin = require "luascripts.wolfadmin.admin.admin"

function commandUnlock(clientId, cmdArguments)
    if cmdArguments[1] == nil or (cmdArguments[1] ~= constants.TEAM_AXIS_SC and cmdArguments[1] ~= constants.TEAM_ALLIES_SC and cmdArguments[1] ~= constants.TEAM_SPECTATORS_SC and cmdArguments[1] ~= "all") then
        return false
    end
    
    if cmdArguments[1] == "all" then
        admin.unlockTeam(constants.TEAM_AXIS)
        admin.unlockTeam(constants.TEAM_ALLIES)
        admin.unlockTeam(constants.TEAM_SPECTATORS)
        
        return false
    end
    
    admin.unlockTeam(util.getTeamFromCode(cmdArguments[1]))
    
    return false
end
commands.addadmin("unlock", commandUnlock, "K", "unlock one or all locked teams", "^9[^3r|b|s|all#^9]", true)