
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

local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local db = wolfa_requireModule("db.db")
local fireteams = wolfa_requireModule("game.fireteams")
local players = wolfa_requireModule("players.players")
local constants = wolfa_requireModule("util.constants")
local settings = wolfa_requireModule("util.settings")
local util = wolfa_requireModule("util.util")
local pagination = wolfa_requireModule("util.pagination")
local util = wolfa_requireModule("util.util")


function commandSlots(clientId, command)
    local playersOnline = {}

    for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
        if players.isConnected(playerId) then
            table.insert(playersOnline, playerId)
        end
    end

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPlayers online: ^7"..(#playersOnline).."\";")


        countallies = 0
        countaxis = 0
        countspecs = 0
    countprivateslots = 0

        for _, player in pairs(playersOnline) do

                if et.gentity_get(player, "pers.connected") == constants.CON_CONNECTED then

                        --axis
                        if tonumber(et.gentity_get(player, "sess.sessionTeam")) == 1 then
                                countaxis = countaxis + 1
                        end
                        --allies
                        if tonumber(et.gentity_get(player, "sess.sessionTeam")) == 2 then
                                countallies = countallies + 1
                        end
                       --specs
                        if tonumber(et.gentity_get(player, "sess.sessionTeam")) == 3 then
                                countspecs = countspecs + 1
                        end

                        if player < tonumber(et.trap_Cvar_Get("sv_privateClients")) then
                                countprivateslots = countprivateslots + 1
                        end

        end


    end


    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dSpectators: ^7"..countspecs.."\";")
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPrivate slots: ^7"..countprivateslots.."\";")

    maxPlayers = tonumber(et.trap_Cvar_Get("sv_maxclients")) - 1
    playersOnline = tonumber(#playersOnline)
    freeSlots = maxPlayers - playersOnline
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dAvailable slots: ^7"..freeSlots.."\";")

    et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dslots: ^9Server statistics were printed to the console.\";")

    return true
end


commands.addclient("slots", commandSlots, auth.PERM_LISTPLAYERS, "display a list of connected players, their slot numbers as well as their admin levels", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("slots", commandSlots, auth.PERM_LISTPLAYERS, "display a list of connected players, their slot numbers as well as their admin levels", nil, nil, (settings.get("g_standalone") == 0))

