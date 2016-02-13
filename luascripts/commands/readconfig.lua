
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015 Timo 'Timothy' Smit

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

local settings = require "luascripts.wolfadmin.util.settings"
local commands = require "luascripts.wolfadmin.commands"
local rules = require "luascripts.wolfadmin.admin.rules"
local greetings = require "luascripts.wolfadmin.players.greetings"

function commandReadconfig(clientId, cmdArguments)
    settings.load()
    local rulesCount = rules.load()
    local greetingsCount = greetings.load()
    
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"readconfig: loaded "..greetingsCount.." greetings, "..rulesCount.." rules\";")
    
    return false
end
commands.register("readconfig", commandReadconfig, "G", "reloads the shrubbot config file and refreshes user flags", nil, true)