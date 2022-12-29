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


-- function from https://www.lua.org/pil/11.5.html
function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

heavyWeapons = Set({et.MOD_GRENADE,
		et.MOD_PANZERFAUST,
		et.MOD_GRENADE_LAUNCHER,
		et.MOD_FLAMETHROWER,
		et.MOD_GRENADE_PINEAPPLE,
		et.MOD_GPG40,
		et.MOD_M7,
		et.MOD_DYNAMITE,
		et.MOD_AIRSTRIKE,
		et.MOD_ARTY,
		et.MOD_SATCHEL,
		et.MOD_MORTAR,
		et.MOD_MORTAR2,
		et.MOD_MOBILE_MG42,
		et.MOD_MOBILE_BROWNING,
		et.MOD_BAZOOKA, })

artyWeapons = Set({et.MOD_AIRSTRIKE,
		et.MOD_ARTY,
		et.MOD_MORTAR,
		et.MOD_MORTAR2, })

mortarWeapons = Set({et.MOD_MORTAR,
		et.MOD_MORTAR2, })

