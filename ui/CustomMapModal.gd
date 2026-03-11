extends CanvasLayer

signal configuration_confirmed(config: Dictionary)
signal cancelled

var w_box: SpinBox
var d_box: SpinBox
var speed_box: SpinBox
var iron_box: SpinBox
var water_box: SpinBox
var cobalt_box: SpinBox
var gadget_box: SpinBox
var relic_box: SpinBox

var center_container: CenterContainer
var panel: PanelContainer
var scroll_container: ScrollContainer

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_cancel()
		get_viewport().set_input_as_handled()

func create_section_label(text: String, app_theme) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 28)
	if app_theme and app_theme.default_font:
		lbl.add_theme_font_override("font", app_theme.default_font)
	lbl.add_theme_color_override("font_color", Color(0.82, 0.65, 0.45))
	return lbl

func create_row(label_text: String, app_theme, sb_min: float, sb_max: float, sb_step: float) -> Array:
	var lbl = Label.new()
	lbl.text = label_text
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 24)
	if app_theme and app_theme.default_font:
		lbl.add_theme_font_override("font", app_theme.default_font)
		
	var hbox = HBoxContainer.new()
	var btn_minus = create_styled_button("-")
	var box = SpinBox.new()
	box.min_value = sb_min
	box.max_value = sb_max
	box.step = sb_step
	box.focus_mode = Control.FOCUS_ALL
	var btn_plus = create_styled_button("+")
	
	hbox.add_child(btn_minus)
	hbox.add_child(box)
	hbox.add_child(btn_plus)
	
	btn_minus.pressed.connect(func(): box.value -= box.step)
	btn_plus.pressed.connect(func(): box.value += box.step)
	
	return [lbl, hbox, box]

func _ready():
	layer = 150
	visible = false
	
	var backdrop = ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.8)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)

	var app_theme = preload("res://gui/theme.tres")

	center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	if app_theme:
		center_container.theme = app_theme
	add_child(center_container)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(550, 650)
	center_container.add_child(panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(main_vbox)

	var title_margin = MarginContainer.new()
	title_margin.add_theme_constant_override("margin_top", 30)
	title_margin.add_theme_constant_override("margin_bottom", 10)
	main_vbox.add_child(title_margin)

	var title = Label.new()
	title.text = "Custom Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	if app_theme and app_theme.default_font:
		title.add_theme_font_override("font", app_theme.default_font)
	title_margin.add_child(title)

	scroll_container = ScrollContainer.new()
	scroll_container.custom_minimum_size = Vector2(500, 420)
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.follow_focus = true
	main_vbox.add_child(scroll_container)

	var m_container = MarginContainer.new()
	m_container.add_theme_constant_override("margin_top", 10)
	m_container.add_theme_constant_override("margin_bottom", 20)
	m_container.add_theme_constant_override("margin_left", 30)
	m_container.add_theme_constant_override("margin_right", 30)
	m_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(m_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	m_container.add_child(vbox)

	var create_grid = func():
		var g = GridContainer.new()
		g.columns = 2
		g.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		g.add_theme_constant_override("h_separation", 20)
		g.add_theme_constant_override("v_separation", 10)
		return g

	vbox.add_child(create_section_label("- Map Dimensions -", app_theme))
	var grid_dim = create_grid.call()
	vbox.add_child(grid_dim)
	var r_width = create_row("Width: ", app_theme, 40, 1000, 5)
	grid_dim.add_child(r_width[0]); grid_dim.add_child(r_width[1]); w_box = r_width[2]
	
	var reset_scroll = func():
		if scroll_container:
			get_tree().process_frame.connect(func(): if scroll_container: scroll_container.scroll_vertical = 0, CONNECT_ONE_SHOT)
	
	for c in [r_width[1].get_child(0), r_width[1].get_child(1), r_width[1].get_child(2), w_box, w_box.get_line_edit()]:
		if c and c.has_signal("focus_entered"):
			c.focus_entered.connect(reset_scroll)

	var r_depth = create_row("Depth: ", app_theme, 40, 1000, 5)
	grid_dim.add_child(r_depth[0]); grid_dim.add_child(r_depth[1]); d_box = r_depth[2]

	vbox.add_child(create_section_label("- Keepers -", app_theme))
	var grid_mut = create_grid.call()
	vbox.add_child(grid_mut)
	var r_speed = create_row("Movement Speed (%): ", app_theme, 25, 500, 10)
	grid_mut.add_child(r_speed[0]); grid_mut.add_child(r_speed[1]); speed_box = r_speed[2]

	vbox.add_child(create_section_label("- Resources -", app_theme))
	var grid_res = create_grid.call()
	vbox.add_child(grid_res)
	var r_iron = create_row("Iron Clusters (%): ", app_theme, 0, 1000, 10)
	grid_res.add_child(r_iron[0]); grid_res.add_child(r_iron[1]); iron_box = r_iron[2]
	var r_water = create_row("Water (%): ", app_theme, 0, 1000, 10)
	grid_res.add_child(r_water[0]); grid_res.add_child(r_water[1]); water_box = r_water[2]
	var r_cobalt = create_row("Cobalt (%): ", app_theme, 0, 1000, 10)
	grid_res.add_child(r_cobalt[0]); grid_res.add_child(r_cobalt[1]); cobalt_box = r_cobalt[2]

	vbox.add_child(create_section_label("- Points of Interest -", app_theme))
	var grid_poi = create_grid.call()
	vbox.add_child(grid_poi)
	var r_gadget = create_row("Gadgets: ", app_theme, 0, 10, 1)
	grid_poi.add_child(r_gadget[0]); grid_poi.add_child(r_gadget[1]); gadget_box = r_gadget[2]
	var r_relic = create_row("Relic Chambers: ", app_theme, 0, 5, 1)
	grid_poi.add_child(r_relic[0]); grid_poi.add_child(r_relic[1]); relic_box = r_relic[2]

	var bottom_margin = MarginContainer.new()
	bottom_margin.add_theme_constant_override("margin_top", 10)
	bottom_margin.add_theme_constant_override("margin_bottom", 30)
	main_vbox.add_child(bottom_margin)

	var h_buttons = HBoxContainer.new()
	h_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	h_buttons.add_theme_constant_override("separation", 40)
	bottom_margin.add_child(h_buttons)
	
	var btn_confirm = create_styled_button(" Confirm ")
	btn_confirm.pressed.connect(_on_confirm)
	h_buttons.add_child(btn_confirm)
	
	var btn_cancel = create_styled_button(" Cancel ")
	btn_cancel.pressed.connect(_on_cancel)
	h_buttons.add_child(btn_cancel)
	
	btn_confirm.focus_neighbor_right = btn_confirm.get_path_to(btn_cancel)
	btn_cancel.focus_neighbor_left = btn_cancel.get_path_to(btn_confirm)
	
	var r_minus = relic_box.get_parent().get_child(0)
	var r_plus = relic_box.get_parent().get_child(2)
	
	btn_confirm.focus_neighbor_top = btn_confirm.get_path_to(r_minus)
	btn_cancel.focus_neighbor_top = btn_cancel.get_path_to(r_plus)
	
	r_minus.focus_neighbor_bottom = r_minus.get_path_to(btn_confirm)
	relic_box.focus_neighbor_bottom = relic_box.get_path_to(btn_confirm)
	r_plus.focus_neighbor_bottom = r_plus.get_path_to(btn_cancel)
	gadget_box.get_parent().get_child(2).focus_neighbor_bottom = gadget_box.get_parent().get_child(2).get_path_to(btn_cancel)
	
	if Engine.has_singleton("Style"):
		Style.init(center_container)
	else:
		var style = get_node_or_null("/root/Style")
		if style:
			style.init(center_container)

func create_styled_button(btn_text: String) -> Button:
	var b = Button.new()
	b.text = btn_text

	var app_theme = preload("res://gui/theme.tres")
	if app_theme and app_theme.has_font("font", "Button"):
		b.add_theme_font_override("font", app_theme.get_font("font", "Button"))
	elif app_theme and app_theme.default_font:
		b.add_theme_font_override("font", app_theme.default_font)

	var btn_normal = preload("res://gui/buttons/button_normal.tres")
	var btn_hover = preload("res://gui/buttons/button_hover.tres")
	var btn_pressed = preload("res://gui/buttons/button_pressed.tres")
	
	if btn_normal:
		b.add_theme_stylebox_override("normal", btn_normal)
	if btn_hover:
		b.add_theme_stylebox_override("hover", btn_hover)
	if btn_pressed:
		b.add_theme_stylebox_override("pressed", btn_pressed)
		
	b.focus_mode = Control.FOCUS_ALL
	return b

var current_blocker

func open_modal(config: Dictionary):
	w_box.value = clamp(config.get("custom_map_width", 70), w_box.min_value, w_box.max_value)
	d_box.value = clamp(config.get("custom_map_depth", 100), d_box.min_value, d_box.max_value)
	speed_box.value = clamp(config.get("custom_keeper_speed", 100), speed_box.min_value, speed_box.max_value)
	iron_box.value = clamp(config.get("custom_iron", 100), iron_box.min_value, iron_box.max_value)
	water_box.value = clamp(config.get("custom_water", 100), water_box.min_value, water_box.max_value)
	cobalt_box.value = clamp(config.get("custom_cobalt", 100), cobalt_box.min_value, cobalt_box.max_value)
	gadget_box.value = clamp(config.get("custom_gadget", 3), gadget_box.min_value, gadget_box.max_value)
	relic_box.value = clamp(config.get("custom_relic", 1), relic_box.min_value, relic_box.max_value)

	visible = true
	
	current_blocker = preload("res://mods-unpacked/Sachtleben-CustomMaps/ui/ModalBlocker.gd").new()
	current_blocker.integrate(self)
	
	if scroll_container:
		scroll_container.scroll_vertical = 0
	
	w_box.get_line_edit().grab_focus()

func close_blocker():
	if current_blocker:
		InputSystem.removeProcessor(current_blocker)
		current_blocker = null

func _on_confirm():
	visible = false
	close_blocker()
	var config = {
		"custom_map_width": int(w_box.value),
		"custom_map_depth": int(d_box.value),
		"custom_keeper_speed": float(speed_box.value),
		"custom_iron": float(iron_box.value),
		"custom_water": float(water_box.value),
		"custom_cobalt": float(cobalt_box.value),
		"custom_gadget": int(gadget_box.value),
		"custom_relic": int(relic_box.value)
	} 
	emit_signal("configuration_confirmed", config)	 

func _on_cancel():
	visible = false
	close_blocker()
	emit_signal("cancelled")
