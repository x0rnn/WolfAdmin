--[[

]]--

local admin = wolfa_requireModule("admin.admin")
local auth = wolfa_requireModule("auth.auth")
local commands = wolfa_requireModule("commands.commands")
local players = wolfa_requireModule("players.players")
local constants = wolfa_requireModule("util.constants")
local settings = wolfa_requireModule("util.settings")


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
    
	message = "^3TeamMuppet is recruiting! Ask recruiters or visit www.teammuppet.com!"
	et.trap_SendServerCommand( -1 , string.format('%s \"%s\"',location,message ))

    return true
end

function tmforum()
    
	message = "^3Visit www.teammuppet.com! Be a part of our community. Share your opinions and suggestions!"
	et.trap_SendServerCommand( -1 , string.format('%s \"%s\"',location,message ))

    return true
end

function tmdiscord()
    
	message = "^3Any questions? Feel free to join our discord for latest server and map updates https://discord.teammuppet.com"
	et.trap_SendServerCommand( -1 , string.format('%s \"%s\"',location,message ))

    return true
end

commands.addadmin("join", jointm, auth.PERM_TMADVERT, "print message how to join TM", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("forum", tmforum, auth.PERM_TMADVERT, "print TM forum url", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("recruit", jointm, auth.PERM_TMADVERT, "print message how to join TM", nil, nil, (settings.get("g_standalone") == 0))
commands.addadmin("discord", tmdiscord, auth.PERM_TMADVERT, "print TM discord url", nil, nil, (settings.get("g_standalone") == 0))