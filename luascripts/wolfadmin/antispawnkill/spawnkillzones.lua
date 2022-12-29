-- spawnAreas["mapname"] define protected zones for mapname (lowercase)

-- spawningTeam: 1 = Axis, 2 = Allies

-- weaponType:
-- 	"mortar" = only mortar
-- 	"arty" = airstrike, artillery or mortar
-- 	empty or anything else = all heavy weapons

-- shape:
-- 	"box" define minCorner and size
--		minCorner: smallest co-ordinate of the box
--	"cylinder" define bottomCenter, radius and height
-- the in-game command /where can be used to find co-ordinates

-- condition: conditions that need to be met before a spawn area is active
-- 	"objectiveCompleted" valid values: aN, xN where N is an integer
-- 	"objectiveFailed" valid values: aN, xN where N is an integer
-- 	"objectivePending" valid values: aN, xN where N is an integer
-- 		aN denotes an allies objective, xN denotes an axis objective
-- 		probably the easiest way to get values for these is to look in the in-game limbomenu
-- 		if the objective is described on page N+1, the corresponding value to set here is N
-- 		the values can also be found in mapname.script. look for wm_objective_status lines
-- 		e.g. the "Steal the tank" objective on goldrush-ga is described on the 2nd page, so
-- 		to activate protected zones after the tank has been stolen, set condition = {objectiveCompleted = "a1"}
-- 		unfortunately, not all maps have objective status, so other conditions might be needed
-- 	"destroyed" targetname of an entity that needs to be destroyed
-- 	"notDestroyed" targetname of an entity that needs to still exist in the map
-- 		sometimes deducible from mapname.script, but it might be necessary to look at mapname.bsp
-- 		although most of the .bsp file is not human-readable, entities are saved in plain text
-- 		e.g. the Main Gate needs to be destroyed before allies secure the 2nd spawn on erdenberg_t2
-- 		looking in the .bsp file, the targetname of this entity is main_gate
-- 		condition = {destroyed = "main_gate"} should be set
-- 		NOTE: sometimes multiple entities share a targetname. make sure to use an entity that has a unique targetname

spawnAreas = {}
spawnAreas["erdenberg_t2"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {540, 410, -200},
		size = {800, 1500, 200}
	},

	-- allies first spawn exit
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {964, 570, -200},
		radius = 600,
		height = 200
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "arty",
		bottomCenter = {964, 720, -200},
		radius = 600,
		height = 200
	},

	-- allies second spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {3394, -829, -220},
		size = {390, 390, 200},
		condition = {destroyed = "main_gate"}
	},

	-- allies second spawn exit
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {3890, -893, -445},
		size = {665, 490, 400},
		condition = {destroyed = "main_gate"}
	},
		
	-- axis backspawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {7234, 100, -500},
		size = {800, 650, 200}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {6706, 18, -500},
		size = {475, 667, 200}
	}
}

spawnAreas["goldrush-ga"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-4000, -1300, -100},
		size = {800, 1800, 400}
	},
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-3200, -250, -50},
		size = {230, 325, 350}
	},

	-- allies tank depot yard
	-- after stealing tank
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-121, 2800, 300},
		size = {275, 700, 400},
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-830, 3134, 300},
		size = {1050, 900, 400},
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {-880, 2500, 300},
		size = {640, 600, 400},
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {-240, 2285, 300},
		size = {300, 500, 400},
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {-140, 2450, 300},
		height = 400,
		radius = 350,
		condition = {objectiveCompleted = "a1"}
	},

	-- axis tank spawn
	-- captureable spawn, only protected from mortar
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-880, 2500, 300},
		size = {640, 600, 400},
		condition = {objectivePending = "a1"}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-240, 2285, 300},
		size = {300, 500, 400},
		condition = {objectivePending = "a1"}
	},
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {-140, 2450, 300},
		height = 400,
		radius = 350,
		condition = {objectivePending = "a1"}
	},

	-- axis gold yard spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {2400, -1310, -500},
		-- careful about making it too high here
		-- there are unprotected areas above
		size = {700, 700, 150}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "arty",
		minCorner = {2760, -1810, -500},
		size = {500, 700, 400}
	},
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2700, -1420, -500},
		height = 400,
		radius = 850
	},
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2350, -740, -500},
		height = 300,
		radius = 600
	}
}

spawnAreas["braundorf_final"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {2577, -5560, 350},
		size = {394, 640, 400}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {2080, -5560, 350},
		size = {500, 640, 400}
	},
	-- command post
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {4900, -160, 250},
		size = {500, 500, 500},
		-- command post constructed
		condition = {objectiveCompleted = "a5"}
	},
	-- axis bunker spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {2482, 270, 0},
		size = {440 ,1800, 250}
	},
	-- allies flag spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {3100, -2550, 140},
		size = {700, 420, 500},
		-- maingate blown
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {3730, -2780, 140},
		size = {390, 650, 500},
		-- maingate blown
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {2610, -2965, 140},
		size = {427, 568, 300},
		-- maingate blown
		condition = {objectiveCompleted = "a1"}
	},
	-- axis flag spawn
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {2861, -2965, 140},
		size = {1285, 867, 150},
		-- maingate not blown
		condition = {objectivePending = "a1"}
	}
}

spawnAreas["radar"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {2360, 2826, 1200},
		size = {677, 1243, 2000}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {1757, 2610, 1200},
		size = {2200, 3758, 2000}
	},

	-- axis bunker entrances
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {413, 1288, 1200},
		size = {307, 312, 1000},
		-- maingate not blown
		condition = {notDestroyed = "maindoor1"}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1136, 2466, 1390},
		-- low height, not above bunker
		size = {425, 563, 150},
		-- maingate not blown
		condition = {notDestroyed = "maindoor1"}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1399, 737, 1200},
		size = {600, 700, 1000},
		-- maingate not blown
		condition = {notDestroyed = "maindoor1"}
	},
	-- allies bunker entrances
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {413, 1288, 1200},
		size = {307, 312, 1000},
		-- maingate blown
		condition = {destroyed = "maindoor1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1136, 2466, 1390},
		-- low height, not above bunker
		size = {425, 563, 150},
		-- maingate blown
		condition = {destroyed = "maindoor1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1399, 737, 1200},
		size = {600, 700, 1000},
		-- maingate blown
		condition = {destroyed = "maindoor1"}
	},
	-- inside bunker
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-1210, 1400, 1200},
		size = {1250, 800, 1000},
		-- maingate blown
		condition = {destroyed = "maindoor1"}
	},

	-- allies CP
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2671, -1623, 1200},
		height = 2000,
		radius = 800,
		-- CP is built
		condition = {objectiveCompleted = "a4"}
	},

	-- axis lower warehouse
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {-1997, -4301, 1200},
		size = {767, 623, 184}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1507, -3600, 1200},
		size = {500, 310, 184}
	},

	-- axis hut
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {-4000, -790, 1200},
		height = 2000,
		radius = 785
	},
}

spawnAreas["bremen_final"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-2400, -2590, 70},
		size = {750, 720, 200}
	},
	-- axis flag
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {-2984, 1427, 70},
		height = 300,
		radius = 750,
		-- main gate hasn't been blown
		condition = {objectivePending = "a2"}
	},

	-- allies flag
	{
		spawningTeam = 2,
		shape = "cylinder",
		bottomCenter = {-2984, 1427, 70},
		height = 300,
		radius = 750,
		-- after main gate has been blown
		condition = {objectiveCompleted = "a2"}
	},
	-- axis back spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {354, -1213, 70},
		size = {513, 315, 300}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {411, -930, 70},
		size = {182, 474, 300}
	},
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {435, -1108, 70},
		height = 400,
		radius = 1100
	},
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "arty",
		bottomCenter = {435, -1108, 70},
		height = 400,
		radius = 800
	},
	-- allies CP
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {1860, 2374, 240},
		height = 400,
		radius = 288,
		-- CP built
		condition = {objectiveCompleted = "a4"}
	},
}

spawnAreas["et_beach"] = {
	-- allies beach spawn
	{
		spawningTeam = 2,
		shape = "cylinder",
		bottomCenter = {-2375, 3433, 0},
		height = 1000,
		radius = 1900
	},
	-- allies flag
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {1400, 3500, 0},
		height = 840,
		radius = 936,
		-- the map incorrectly defines "failed" status when allies are holding the flag
		condition = {objectiveFailed = "a4"}
	},
	-- axis spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {2384, 2960, 1150},
		size = {606, 413, 150}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {2350, 2414, 950},
		size = {447, 959, 226}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {2350, 2414, 950},
		size = {447, 959, 226}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {2778, 2191, 900},
		size = {502, 888, 500}
	},
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "mortar",
		minCorner = {2814, 1711, 900},
		size = {265, 383, 100}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {3152, 1616, 900},
		size = {400, 440, 150}
	}
}

spawnAreas["sw_oasis_b3"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "cylinder",
		bottomCenter = {831, 2664, -700},
		height = 2000,
		radius = 930
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		bottomCenter = {2980, 2571, -700},
		height = 2000,
		radius = 1000
	},
	-- axis flag
	{
		spawningTeam = 1,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {3720, 7300, -700},
		height = 2000,
		radius = 550,
		-- wall not blown
		condition = {objectivePending = "a3"}
	},
	-- allies flag
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {3440, 6012, -500},
		size = {1560, 1570, 2000},
		-- wall blown
		condition = {objectiveCompleted = "a3"}
	},
	-- axis backspawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {6966, 4214, -500},
		size = {1030, 960, 350}
	}
}

spawnAreas["caen2"] = {
	-- axis first spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {-1792, -2391, 300},
		size = {440, 380, 200}
	},
	-- axis first spawn outside
	{
		spawningTeam = 1,
		shape = "box",
		weaponType = "arty",
		minCorner = {-2492, -2458, 200},
		size = {1392, 908, 1000}
	},
	-- allies flag
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1296, 646, 200},
		size = {877, 945, 400},
		-- tank not moved
		condition = {objectivePending = "x2"}
	},
	-- axis flag
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {-1296, 664, 200},
		size = {1220, 820, 400},
		-- tank moved
		condition = {objectiveCompleted = "x2"}
	},
	-- allies back spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-2640, 5810, 500},
		size = {1406, 580, 300}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {-1750, 5560, 200},
		size = {1070, 1000, 1500}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "mortar",
		minCorner = {-1750, 5420, 200},
		size = {1330, 1000, 1500}
	}
}

spawnAreas["etl_adlernest"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {2075, -1485, -200},
		size = {1725, 1445, 400},
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2745, -1475, -200},
		height = 400,
		radius = 680
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2075, -215, -200},
		height = 400,
		radius = 400
	},
	-- axis spawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {-1950 -733, 64},
		size = {776, 635, 200}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {-1175 -458, 64},
		size = {197, 371, 200}
	}
}

spawnAreas["etl_supply"] = {
	-- allies first spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-2400, -224, 0},
		size = {550, 654, 500}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {-2680, -229, 0},
		size = {1405, 1245, 500}
		
	},
	-- allies flag spawn
	{
		spawningTeam = 2,
		shape = "box",
		minCorner = {-445, 2116, 250},
		size = {355, 520, 500},
		-- after main gate blown
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "box",
		weaponType = "arty",
		minCorner = {-45, 1733, -200},
		size = {934, 1500, 2000},
		-- after main gate blown
		condition = {objectiveCompleted = "a1"}
	},
	{
		spawningTeam = 2,
		shape = "cylinder",
		weaponType = "mortar",
		bottomCenter = {2565, 848, 150},
		height = 200,
		radius = 500,
		-- allies CP built
		condition = {objectiveCompleted = "a8"}
	},
	-- axis backspawn
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {330, -1946, -150},
		size = {595, 348, 100}
	},
	{
		spawningTeam = 1,
		shape = "box",
		minCorner = {704, -1591, -150},
		size = {94, 205, 250}
	}
}
