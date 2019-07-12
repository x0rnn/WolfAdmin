--[[

]]--


local admin = require (wolfa_getLuaPath()..".admin.admin")
local auth = require (wolfa_getLuaPath()..".auth.auth")
local commands = require (wolfa_getLuaPath()..".commands.commands")
local players = require (wolfa_getLuaPath()..".players.players")
local constants = require (wolfa_getLuaPath()..".util.constants")
local settings = require (wolfa_getLuaPath()..".util.settings")

location = "cp"								--location of the message

--[[
bp - banner area
cp - centerprint area
cpm - left popup area
print - console
chat - player chat area
qsay - server say
--]]


function jointm()
    
	message = "TeamMuppet is recruiting! Ask recruiters or visit www.teammuppet.com!"
	et.trap_SendServerCommand( -1 , string.format('%s \"%s\"',location,message ))

    return true
end

function tmforum()
    
	message = "Visit www.teammuppet.com! Be a part of our community. Share your opinions and suggestions!"
	et.trap_SendServerCommand( -1 , string.format('%s \"%s\"',location,message ))

    return true
end



commands.addadmin("join", jointm, auth.PERM_TMADVERT, "print message how to join TM", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("forum", tmforum, auth.PERM_TMADVERT, "print TM forum url", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("recruit", jointm, auth.PERM_TMADVERT, "print message how to join TM", nil, nil, (settings.get("g_standalone") == 0))