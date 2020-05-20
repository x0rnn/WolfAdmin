
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

function commandListPlayersByNickname(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsearchplayer: ^9player history is disabled.\";")

        return true
    elseif victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsearchplayer usage: !showplayers [nickname] [offset/page]\";")

        return true
    else
        cmdClient = victim
    end

	local count = db.getAliasByNicknameCount(victim)
	local limit, offset = pagination.calculate(count, 30, tonumber(offset))
	local aliases = db.getAliasByNickname(victim, limit, offset)
	
	if not count or count == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dsearchplayer: ^9there is no history for selected player nickname(s) ^7"..victim.."^9.\";")
    else	

		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dPlayers: \";")
		for _, alias in pairs(aliases) do
			local numberOfSpaces = 24 - string.len(util.removeColors(alias["alias"]))
			local spaces = string.rep(" ", numberOfSpaces)
			
			et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9 Player ID: ^1"..string.format("%6s", alias["player_id"]).."^9 Nickname: ^7"..spaces..alias["alias"].." ^9 Seen: ^7"..string.format("%8s", alias["used"]).."^9 times  Last time: ^7"..os.date("%d/%m/%Y", alias["lastused"]).."\";")
		end
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^9Showing history of nicknames ^7"..victim.."^9 results: ^7"..(offset + 1).." ^9- ^7"..(offset + limit).." ^9of ^7"..count.."^9.\";")			
    end

    return true
end
commands.addadmin("searchplayer", commandListPlayersByNickname, auth.PERM_SEARCHPLAYER, "display history for a specific player nickname", "^9[^3nickname^9] ^9(^hoffset^9)", (settings.get("g_playerHistory") == 0))
