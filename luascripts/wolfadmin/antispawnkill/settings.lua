-- Based on original Anti-Spawnkill module by DM hazz#4857
-- WolfAdmin module for Wolfenstein: Enemy Territory servers.
-- Copyright (C) 2015-2020 Timo 'Timothy' Smit
-- extended by <=TM=>EAGLE_CZ, www.teammuppet.com

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

-- ---------------------------------------------------------------------------
-- set g_antispawnkill = 0 - do nothing, warn only
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

