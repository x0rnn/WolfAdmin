
local auth = require (wolfa_getLuaPath()..".auth.auth")
local history = require (wolfa_getLuaPath()..".admin.history")
local db = require (wolfa_getLuaPath()..".db.db")
local commands = require (wolfa_getLuaPath()..".commands.commands")
local util = require (wolfa_getLuaPath()..".util.util")
local pagination = require (wolfa_getLuaPath()..".util.pagination")
local settings = require (wolfa_getLuaPath()..".util.settings")

function commandListPlayerByGUID(clientId, command, victim, offset)
    local cmdClient

    if not db.isConnected() or settings.get("g_playerHistory") == 0 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowhistory: ^9player history is disabled.\";")

        return true
    elseif victim == nil then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowguid usage: !showguid [GUID] [offset/page]\";")

        return true
    else
        cmdClient = victim
    end

	et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^muheeeee "..victim..".\";")

	--playerGUID = {} 
	playerGUID = db.getPlayer(victim)
	
	if not (playerGUID) then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "csay "..clientId.." \"^dshowguid: ^9there is no history for selected player GUID ^7"..victim.."^9.\";")
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
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "cchat "..clientId.." \"^dshowguid: ^9history for GUID ^7"..victim.." ^9was printed to the console.\";")
    end

    return true
end
commands.addadmin("showguid", commandListPlayerByGUID, auth.PERM_SHOWGUID, "display history for a specific player", "^9[^3GUID^9] ^9(^hoffset^9)", (settings.get("g_playerHistory") == 0))
