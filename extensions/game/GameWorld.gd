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

		# Make sure it stays customized for UI and loading configurations
		modeConfig[CONST.MODE_CONFIG_MAP_ARCHETYPE] = "regular-custom"
