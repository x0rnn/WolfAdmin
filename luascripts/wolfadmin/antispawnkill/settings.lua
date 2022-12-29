-- set g_antispawnkill = 1 - ban the player
-- set g_antispawnkill = 2 - move to spec

-- timeout length after kick (seconds)
-- positive integer
bantime = 900

-- how often warnings are issued (milliseconds)
-- 500 is a reasonable default and probably shouldn't be changed
-- non-negative integer
warnInterval = 500

-- how often the same client can be warned (milliseconds)
-- setting this below 5000 might cause too many warnings
-- non-negative integer
warnCooldown = 20000

-- non-negative integer
warningsBeforeGib = 1

-- non-negative integer
warningsBeforeKick = 2

-- if true, won't warn/gib/kick anyone for spawnkill
-- boolean
disableWarnings = false

-- cancel out any damage dealt if it counts as spawnkill damage
-- targets will still get knocked around by knockback
-- probably should be combined with disableWarnings = true or very high warningsBeforeGib and warningsBeforeKick
-- boolean
spawnkillImmunity = false

-- message to show to players at the start of the map
-- set to "" to disable
-- max length: 107 characters excluding colour changes
customMessage = "Contact ^2TeamMuppet^7 staff or DM hazz#4857 for bug reports, feature requests or badly defined spawn areas"

