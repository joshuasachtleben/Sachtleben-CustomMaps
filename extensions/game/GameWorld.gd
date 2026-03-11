extends "res://game/GameWorld.gd"

func prepareRegularLevelStart(levelStartData: LevelStartData):
	var modeConfig = levelStartData.loadout.modeConfig
	var archetypeName = modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "regular-medium")
	
	if archetypeName == "regular-custom":
		# Trick the base game by injecting huge temporarily to reuse generation logic
		levelStartData.mapArchetype = load("res://content/map/generation/archetypes/regular-huge.tres").duplicate()
	
	# Sanitize any missing/old modifiers from dirty saves before base game tries to parse them
	var modeModifiers = modeConfig.get(CONST.MODE_CONFIG_WORLDMODIFIERS, [])
	var safeModifiers = []
	for mod_id in modeModifiers:
		if Data.worldModifiers.has(mod_id):
			safeModifiers.append(mod_id)
	modeConfig[CONST.MODE_CONFIG_WORLDMODIFIERS] = safeModifiers
	
	super.prepareRegularLevelStart(levelStartData)
	
	if archetypeName == "regular-custom":
		var custom_width = int(modeConfig.get("custom_map_width", 70))
		var custom_depth = int(modeConfig.get("custom_map_depth", 100))
		
		# Allow sizes much larger than the base game
		levelStartData.mapArchetype.width = custom_width
		levelStartData.mapArchetype.depth = custom_depth
		# A huge map is 70x100 = 7000 tiles, tileCount=6000 (~0.85 ratio)
		levelStartData.mapArchetype.tileCount = int(custom_width * custom_depth * 0.85)

		# Custom Resource Multipliers
		var mult_iron = float(modeConfig.get("custom_iron", 100)) / 100.0
		var mult_water = float(modeConfig.get("custom_water", 100)) / 100.0
		var mult_cobalt = float(modeConfig.get("custom_cobalt", 100)) / 100.0

		levelStartData.mapArchetype.iron_cluster_rate *= mult_iron
		levelStartData.mapArchetype.water_rate *= mult_water
		levelStartData.mapArchetype.cobalt_rate *= mult_cobalt

		# Custom Chambers
		levelStartData.mapArchetype.relics = int(modeConfig.get("custom_relic", 1))
		levelStartData.mapArchetype.gadgets = int(modeConfig.get("custom_gadget", 3))

		# Make sure it stays customized for UI and loading configurations
		modeConfig[CONST.MODE_CONFIG_MAP_ARCHETYPE] = "regular-custom"

func levelInitialized():
	super.levelInitialized()
	var modeConfig = Level.loadout.modeConfig if Level and Level.loadout else {}
	if modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "") == "regular-custom":
		var speed_mult = float(modeConfig.get("custom_keeper_speed", 100)) / 100.0
		if speed_mult != 1.0:
			for keeper in Keepers.getAll():
				if "playerId" in keeper and "techId" in keeper:
					var base_speed = Data.of(keeper.playerId + "." + keeper.techId + ".maxSpeed")
					var extra_speed = base_speed * (speed_mult - 1.0)
					Data.changeByInt(keeper.playerId + ".keeper.speedBuff", int(extra_speed))
