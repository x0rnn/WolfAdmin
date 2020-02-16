-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2017 Timo 'Timothy' Smit

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
local players = wolfa_requireModule("players.players")
local settings = wolfa_requireModule("util.settings")

function commandRecruiterChat(clientId, command, ...)
    if not ... then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9usage: "..commands.getclient("recruiterchat")["syntax"].."\";")
    else
        local recipients = {}
        
        for playerId = 0, et.trap_Cvar_Get("sv_maxclients") - 1 do
            if players.isConnected(playerId) and auth.isPlayerAllowed(playerId, auth.PERM_RECRUITERCHAT) then
                table.insert(recipients, playerId) 
            end
        end
        
        for _, recipient in ipairs(recipients) do
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..recipient.." \"^7"..et.gentity_get(clientId, "pers.netname").."^7 -> recruiterchat ("..#recipients.." recipients): ^d"..table.concat({...}, " ").."\";")
            et.trap_SendServerCommand(recipient, "cp \"^jrecruiterchat message from ^7"..et.gentity_get(clientId, "pers.netname"))
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound "..recipient.." \"sound/misc/pm.wav\";")
        end
        
        et.G_LogPrint("recruiterchat: "..et.gentity_get(clientId, "pers.netname")..": "..table.concat({...}, " ").."\n")
    end
    
    return true
end
commands.addclient("recruiterchat", commandRecruiterChat, auth.PERM_RECRUITERCHAT, "[^2message^7]", true)
commands.addclient("mr", commandRecruiterChat, auth.PERM_RECRUITERCHAT, "[^2message^7]", true)
commands.addadmin("mr", commandRecruiterChat, auth.PERM_RECRUITERCHAT, "send private message to all recruiters online", "^9/mr message", nil, (settings.get("g_standalone") == 0))