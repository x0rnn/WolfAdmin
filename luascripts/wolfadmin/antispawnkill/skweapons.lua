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

