-- WolfAdmin definitions
local auth = wolfa_requireModule("auth.auth")
local history = wolfa_requireModule("admin.history")
local db = wolfa_requireModule("db.db")
local commands = wolfa_requireModule("commands.commands")
local players = wolfa_requireModule("players.players")
local settings = wolfa_requireModule("util.settings")
local stats = wolfa_requireModule("players.stats")
local admin = wolfa_requireModule("admin.admin")
local bits = wolfa_requireModule("util.bits")
local events = wolfa_requireModule("util.events")
local timers = wolfa_requireModule("util.timers")
local constants = wolfa_requireModule("util.constants")
local util = wolfa_requireModule("util.util")

-- Anti-Spawnkill definitions
local version = 0.3
local storedLevelTime = 0
local spawnkillerSet = {}
local spawnkillWarnings = {}
local lastFlameDamage = {}
local currentMap = string.lower(et.trap_Cvar_Get("mapname"))
local antispawnkillActive = true
local destroyTargets = {}
local printDelay = 5000
local printInitTime
local printDone = false

local antispawnkill = {}

-- handle g_antispawnkill setting from server.cfg
-- set g_antispawnkill = 0  - do nothing, only warn
-- set g_antispawnkill = 1  - ban the player
-- set g_antispawnkill = 2  - move to spec
local antispawnkill_action = et.trap_Cvar_Get("g_antispawnkill")
if tonumber(antispawnkill_action) == nil or tonumber(antispawnkill_action) == 0 then
	et.G_Print("Anti-spawnkill: No action will be done with spawnkiller via set g_antispawnkill = 0 [1 = ban, 2 = spec]\n")
	antispawnkill_action = 0
else
	-- ban
	if tonumber(antispawnkill_action) == 1 then
		et.G_Print("Anti-spawnkill: Spawnkill will ban the player via set g_antispawnkill = 1  \n")
		antispawnkill_action = 1
		
	end	
	-- spec
	if tonumber(antispawnkill_action) == 2 then
		et.G_Print("Anti-spawnkill: Spawnkill will move the player to spectators via set g_antispawnkill = 2  \n")
		antispawnkill_action = 2
	end	
end 

function getCwd()
	antiskdir = "luascripts/wolfadmin/antispawnkill/"
	modname = et.trap_Cvar_Get("fs_game") .. "/"
	basepath = et.trap_Cvar_Get("fs_basepath") .. "/"
	homepath = et.trap_Cvar_Get("fs_homepath") .. "/"
	-- following convention, check fs_homepath first
	cwd = homepath .. modname .. antiskdir
	if loadfile(cwd .. "antispawnkill.lua") then
		et.G_Print("Anti-spawnkill: Setting working directory to <fs_homepath>/" .. modname .. antiskdir .. "\n")
		return cwd
	end
	-- only fall back to fs_basepath if the module was not found in fs_homepath
	cwd = basepath .. modname .. antiskdir
	if loadfile(cwd .. "antispawnkill.lua") then
		et.G_Print("Anti-spawnkill: Setting working directory to <fs_basepath>/" .. modname .. antiskdir .. "\n")
		return cwd
	end
	return nil
end
local cwd = getCwd()
if cwd then
	dofile(cwd .. "spawnkillzones.lua")
	et.G_Print("Anti-spawnkill: Successfully loaded spawnkill zones\n")
	dofile(cwd .. "settings.lua")
	et.G_Print("Anti-spawnkill: Successfully loaded settings\n")
	dofile(cwd .. "skweapons.lua")
	et.G_Print("Anti-spawnkill: Successfully loaded weapon definitions\n")
else
	et.G_Print("Anti-spawnkill: Failed to locate working directory. Is antispawnkill.lua in " .. modname .. "antispawnkill?\n")
	antispawnkillActive = false
end

function prettyTime(seconds)
	seconds = tonumber(seconds)
	local secending
	local minending
	local minutes = 0
	while seconds-60 >= 0 do
		minutes = minutes + 1
		seconds = seconds - 60
	end
	if seconds == 1 then
		secending = "second"
	else 
		secending = "seconds"
	end
	if minutes == 1 then
		minending = "minute"
	else
		minending = "minutes"
	end
	if seconds > 0 then
		if minutes > 0 then
			return minutes .. " " .. minending .. " " .. seconds .. " " .. secending
		else
			return seconds .. " " .. secending
		end
	end
	return minutes .. " " .. minending
end

function getGuid(clientNum)
	return et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")
end

function getName(clientNum)
	return et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name")
end

function getTeam(clientNum)
	return et.gentity_get(clientNum, "sess.sessionTeam")
end

function getPlayerLocation(clientNum)
	return et.gentity_get(clientNum, "ps.origin")
end

function getLeveltime()
	return et.trap_Milliseconds()
end

function isWarmup()
	if string.len(et.trap_GetConfigstring(et.CS_WARMUP)) > 0 then
		return true
	end
	return false
end

function isPlayer(entityNum)
	-- entity numbers 0-63 are always reserved for players,
	-- even if sv_maxclients < 64
	if entityNum >= 0 and entityNum < 63 then
		return true
	end
	return false
end

function euclideanDistance2d(p, q)
	return math.sqrt( (p[1]-q[1])^2 + (p[2]-q[2])^2 )
end

function pointInCylinder(point, bottomCenter, radius, height)
	if point[3] < bottomCenter[3] or point[3] > bottomCenter[3] + height then
		return false
	end
	if euclideanDistance2d(point, bottomCenter) > radius then
		return false
	end
	return true
end

function pointInBox(point, minCorner, size)
	for idx, coord in ipairs(point) do
		if coord < minCorner[idx] or coord > minCorner[idx] + size[idx] then
			return false
		end
	end
	return true
end

function pointInArea(point, spawnArea)
	if spawnArea["shape"] == "box" then
		return pointInBox(point, spawnArea["minCorner"], spawnArea["size"])
	end
	if spawnArea["shape"] == "cylinder" then
		return pointInCylinder(point, spawnArea["bottomCenter"], spawnArea["radius"], spawnArea["height"])
	end
	-- fail silently if spawnArea shape is not defined or defined badly
	return false
end

-- status: 0 = pending, 1 = completed, 2 = failed
function hasObjectiveStatus(obj, status)
	obj_configstring = et.trap_GetConfigstring(et.CS_MULTI_OBJECTIVE)
	if tonumber(et.Info_ValueForKey(obj_configstring, obj)) == status then
		return true
	end
	return false
end

function isDestroyed(targetname)
	-- this works because destroyed entities are unlinked at runtime,
	--+so the return values becomes nil
	if et.gentity_get(destroyTargets[targetname], "targetname") then
		return false
	end
	return true
end

function conditionsMet(spawnArea)
	if spawnArea["condition"] == nil then
		return true
	end

	for conditionType, value in pairs(spawnArea["condition"]) do
		if conditionType == "destroyed" then
			if not isDestroyed(value) then
				return false
			end
		elseif conditionType == "notDestroyed" then
			if isDestroyed(value) then
				return false
			end
		elseif conditionType == "objectivePending" then
			if not hasObjectiveStatus(value, 0) then
				return false
			end
		elseif conditionType == "objectiveCompleted" then
			if not hasObjectiveStatus(value, 1) then
				return false
			end
		elseif conditionType == "objectiveFailed" then
			if not hasObjectiveStatus(value, 2) then
				return false
			end
		end
	end

	return true
end

function isSpawnkill(target, meansOfDeath)
	local playerLocation = getPlayerLocation(target)
	for _, spawnArea in ipairs(spawnAreas[currentMap]) do
		if getTeam(target) ~= spawnArea["spawningTeam"] then goto continue end
		if spawnArea["weaponType"] == "mortar" and not mortarWeapons[meansOfDeath] then goto continue end
		if spawnArea["weaponType"] == "arty" and not artyWeapons[meansOfDeath] then goto continue end
		if not heavyWeapons[meansOfDeath] then goto continue end

		if pointInArea(playerLocation, spawnArea) and conditionsMet(spawnArea)  then
			return true
		end
		::continue::
	end
	return false
end

function warnSpawnkill(clientNum)
	-- the below statement could be used to drop the offender out of their team
	--+instead of gibbing or kicking
	--et.trap_SendConsoleCommand(et.EXEC_APPEND, "forceteam " .. clientNum .. " s;")

	local clientGuid = getGuid(clientNum)
	local issuedWarnings = spawnkillWarnings[clientGuid]["warningCount"] + 1
	local playerName = getName(clientNum)

	spawnkillWarnings[clientGuid]["warningCount"] = issuedWarnings
	spawnkillWarnings[clientGuid]["lastWarning"] = getLeveltime()

	if issuedWarnings > warningsBeforeKick then
	
	if string.len(et.trap_GetConfigstring(et.CS_WARMUP)) > 0 then
		local warmup_desc = " (WARMUP) "
	end
		
		if not isWarmup() then
				
			-- what to do if someone is breaking the rules
			
			-- g_antispawnkill 0 = nothing
			if tonumber(antispawnkill_action) == 0 then
				-- drop client
				if settings.get("g_playerHistory") ~= 0 then
					db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Continuously spawnkilled on map: "..string.lower(et.trap_Cvar_Get("mapname")).." - already warned " ..issuedWarnings.. " times.")
				end
			end
			
			-- g_antispawnkill 1 = ban
			if tonumber(antispawnkill_action) == 1 then
				-- drop client
				if settings.get("g_playerHistory") ~= 0 then
					db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Banned on map: "..string.lower(et.trap_Cvar_Get("mapname")).." - already warned " ..issuedWarnings.. " times.")
				end
				
				ban_desc = "You have been banned, due Anti-Spawnkill rule on map "..string.lower(et.trap_Cvar_Get("mapname")).."."
				db.addBan(db.getPlayerId(clientNum), 1, os.time(), bantime, ban_desc)
				et.trap_DropClient(clientNum, ban_desc, 0)
			end
			
			if tonumber(antispawnkill_action) == 2 then
				-- g_antispawnkill 2 = spec
				-- move to spec
				if settings.get("g_playerHistory") ~= 0 then
					db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Moved to spectators on map: "..string.lower(et.trap_Cvar_Get("mapname")).." - already warned " ..issuedWarnings.. " times.")
				end
				et.trap_SendConsoleCommand(et.EXEC_APPEND, "forceteam " .. clientNum .. " s;")
			
			end	
						
		else
			et.trap_SendServerCommand(-1, "cpm \"^7Anti-spawnkill: " .. playerName ..
			"^7 would be kicked if it wasn't warmup!\n\"")
		end
	
	elseif issuedWarnings > warningsBeforeGib then
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/misc/referee.wav\";")
		et.trap_SendServerCommand(-1, "cpm \"^1Anti-Spawnkill: Warning ^7[" .. issuedWarnings .. "/" .. warningsBeforeKick .. "] " ..
		playerName .. "^7: No heavy weapons in spawn!\n\"")

		if warningsBeforeKick - issuedWarnings == 1 then
			et.trap_SendServerCommand(clientNum, "bp \"^7Anti-Spawnkill: You were ^1GIBBED ^7because you dealt damage in a spawn area! " ..
			warningsBeforeKick - issuedWarnings .. " warning left before kick.\n\"")
			db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Warned on map: "..string.lower(et.trap_Cvar_Get("mapname"))..""..warmup_desc.." Count: " ..issuedWarnings.. " / "..warningsBeforeKick)
		else
			et.trap_SendServerCommand(clientNum, "bp \"^7Anti-Spawnkill: You were ^1GIBBED ^7because you dealt damage in a spawn area! " ..
			warningsBeforeKick - issuedWarnings .. " warnings left before kick.\n\"")
			db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Warned on map: "..string.lower(et.trap_Cvar_Get("mapname"))..""..warmup_desc.." Count: " ..issuedWarnings.. " / "..warningsBeforeKick)
		end


		et.G_Damage(clientNum, 0, 1022, 999, 0, 35)
	else
		et.trap_SendConsoleCommand(et.EXEC_APPEND, "playsound \"sound/misc/referee.wav\";")
		et.trap_SendServerCommand(-1, "cpm \"^1Anti-Spawnkill: Warning ^7[" .. issuedWarnings .. "/" .. warningsBeforeKick .. "] " ..
		playerName .. "^7: No heavy weapons in spawn!\n\"")
		
		if warningsBeforeKick - issuedWarnings == 1 then
			et.trap_SendServerCommand(clientNum, "bp \"^7Anti-Spawnkill: You were ^1WARNED ^7because you dealt damage in a spawn area! " ..
			warningsBeforeKick - issuedWarnings .. " warning left before kick.\n\"")
			db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Warned on map: "..string.lower(et.trap_Cvar_Get("mapname")).." "..warmup_desc.." Count: " ..issuedWarnings.. " / "..warningsBeforeKick)
		else
			et.trap_SendServerCommand(clientNum, "bp \"^7Anti-Spawnkill: You were ^1WARNED ^7because you dealt damage in a spawn area! " ..
			warningsBeforeKick - issuedWarnings .. " warnings left before kick.\n\"")
			db.addHistory(db.getPlayerId(clientNum), 1, "Anti-Spawnkill", os.time(), "Warned on map: "..string.lower(et.trap_Cvar_Get("mapname")).." "..warmup_desc.." Count: " ..issuedWarnings.. " / "..warningsBeforeKick)
		end
	end

end

function processSpawnkillers()
	for idx, _ in pairs(spawnkillerSet) do
		warnSpawnkill(idx)
		spawnkillerSet[idx] = nil
	end
end

function mapHasSpawnkillareas()
	if spawnAreas[currentMap] == nil then 
		et.G_Print("Anti-spawnkill: No spawnkill areas defined for " .. currentMap .. "\n")
		return false
	end
	return true
end

function addConditionTargets()
	local targets = {}
	for _, spawnArea in ipairs(spawnAreas[currentMap]) do
		if spawnArea["condition"] == nil then goto continue end

		if spawnArea["condition"]["destroyed"] ~= nil then
			targets[spawnArea["condition"]["destroyed"]] = true
		end
		if spawnArea["condition"]["notDestroyed"] ~= nil then
			targets[spawnArea["condition"]["notDestroyed"]] = true
		end

		::continue::
	end

	for i=0,1023 do
		local targetname = et.gentity_get(i, "targetname")
		if not (targetname == nil) then
			if targets[targetname] then
				et.G_Print("Anti-spawnkill: Found destroy condition entity " .. targetname .. " with id " .. i .. "\n")
				destroyTargets[targetname] = i
			end
		end
	end
end

function startPrints()
	et.trap_SendServerCommand(-1, "cpm \"^zAnti-spawnkill: ^5" .. currentMap ..
	"^7 has spawnkill protection. Spawnkillers will be ^1warned^5 " .. warningsBeforeKick .. "^7 times.\n\"")
	et.trap_SendServerCommand(-1, "cpm \"^zAnti-spawnkill: ^7After ^1warnings^7, offenders will be kicked for ^5" ..
	prettyTime(bantime) .. "^7.\n\"")
	if customMessage and string.len(customMessage) > 0 then
		et.trap_SendServerCommand(-1, "cpm \"^zAnti-spawnkill: ^7" .. customMessage .. "\n\"")
	end
end

-- callbacks
-- using WA to handle game status
function antispawnkill.onGameInit(levelTime, randomSeed, restartMap)
	et.G_Print("Anti-spawnkill: Starting up ...\n")
	storedLevelTime = levelTime

	antispawnkillActive = mapHasSpawnkillareas()
	printInitTime = levelTime
	
	if antispawnkillActive then
		--printInitTime = levelTime
		addConditionTargets()
	end
end

-- using WA to handle player status
function antispawnkill.onClientBegin(clientNum)
	local clientGuid = getGuid(clientNum)
	spawnkillWarnings[clientGuid] = {warningCount = 0, lastWarning = 0}
	lastFlameDamage[clientNum] = 0
end

function et_Damage(target, attacker, damage, damageFlags, meansOfDeath)
	if not antispawnkillActive then return 0 end
	if not (isPlayer(target) and isPlayer(attacker)) then return 0 end
	if not (getTeam(target) ~= getTeam(attacker)) then return 0 end

	-- only consider initial damage with flamethrower
	-- this is to prevent people from causing unwarranted warnings by
	--+running into spawn areas while burning
	if meansOfDeath == et.MOD_FLAMETHROWER then
		if lastFlameDamage[target] + 1500 > getLeveltime() then
			lastFlameDamage[target] = getLeveltime()
			return 0
		end
		lastFlameDamage[target] = getLeveltime()
	end

	if not isSpawnkill(target, meansOfDeath) then return 0 end

	-- spawnkill detected! warn the player
	-- only warn if they haven't been warned in the last <warnCooldown> milliseconds
	if spawnkillWarnings[getGuid(attacker)]["lastWarning"] + warnCooldown < getLeveltime() then
		spawnkillerSet[attacker] = true
	end

	if spawnkillImmunity then
		-- don't deal damage
		return 1
	end
end

-- check for spawnkills every <warnInterval> milliseconds
-- this is done because otherwise a player might get over-punished for 
--+hitting two enemies with one explosive
-- using WA to handle game status
function antispawnkill.onGameFrame(levelTime)
	if not printDone and (levelTime - printInitTime) > printDelay then
		printDone = true
		startPrints()
	end
	if (levelTime - storedLevelTime) > warnInterval then
		storedLevelTime = levelTime
		if not disableWarnings then
			processSpawnkillers()
		end
	end
end
events.handle("onGameFrame", antispawnkill.onGameFrame)
events.handle("onGameInit", antispawnkill.onGameInit)
events.handle("onClientBegin", antispawnkill.onClientBegin)
