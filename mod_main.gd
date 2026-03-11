extends Node

const CUSTOM_MAPS_LOG = "Sachtleben-CustomMaps"
const CUSTOM_MAPS_DIR := "Sachtleben-CustomMaps"
var dir := ""
var ext_dir := ""

var custom_modal_scene = preload("res://mods-unpacked/Sachtleben-CustomMaps/ui/CustomMapModal.gd")
var modal_instance: CanvasLayer

func _init():
	ModLoaderLog.info("Init", CUSTOM_MAPS_LOG)
	dir = ModLoaderMod.get_unpacked_dir() + CUSTOM_MAPS_DIR + "/"
	ext_dir = dir + "extensions/"
	ModLoaderMod.install_script_extension(ext_dir + "game/GameWorld.gd")
	add_to_group("mod_init")

func _ready():
	modal_instance = custom_modal_scene.new()
	add_child(modal_instance)
	modal_instance.connect("configuration_confirmed", Callable(self, "_on_configuration_confirmed"))
	
	get_tree().node_added.connect(Callable(self, "_on_node_added"))

var current_base_node: Node

func _on_node_added(node: Node):
	if node.name == "MapsizeContainers":
		if not node.is_connected("child_entered_tree", Callable(self, "_on_mapsize_child_added")):
			node.connect("child_entered_tree", Callable(self, "_on_mapsize_child_added").bind(node))

func _on_mapsize_child_added(_child: Node, pgc: Node):
	if not pgc.has_meta("sachtleben_injected"):
		var base_node = pgc
		while base_node and not base_node.has_method("mapSizeSelected"):
			base_node = base_node.get_parent()

		if base_node:
			current_base_node = base_node
			pgc.set_meta("sachtleben_injected", true)
			call_deferred("inject_custom_map_sizes", base_node, pgc)
func inject_custom_map_sizes(base_node: Node, pgc: Node):
	var ms = "regular-custom"
	var e = preload("res://stages/loadout/LoadoutChoice.tscn").instantiate()
	e.loadoutScale = 2.0
	e.name = ms
	e.setChoice("Custom Settings", ms, null, "Configure custom map sizes, resources, and speed mutators")
	pgc.add_child(e)
	
	e.connect("select", Callable(base_node, "mapSizeSelected").bind(ms))
	e.connect("select", Callable(base_node, "updateBlockVisibility"))
	e.connect("select", Callable(self, "_on_custom_map_selected"))
	
	var pre_conf = Level.loadout.modeConfig.get(CONST.MODE_CONFIG_MAP_ARCHETYPE, "") 
	if pre_conf == ms:
		base_node.mapSizeSelected(ms)

func _on_custom_map_selected():
	modal_instance.open_modal(Level.loadout.modeConfig)

func _on_configuration_confirmed(config: Dictionary):
	for key in config:
		Level.loadout.modeConfig[key] = config[key]
	if current_base_node and is_instance_valid(current_base_node) and current_base_node.has_method("resetPersistMetaCooldown"):
		current_base_node.resetPersistMetaCooldown()

func modInit():
	pass


