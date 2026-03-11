extends CanvasLayer

signal dimensions_confirmed(width, depth)
signal cancelled

var w_box: SpinBox
var d_box: SpinBox

var center_container: CenterContainer
var panel: PanelContainer

func _ready():
	layer = 150
	visible = false
	
	var backdrop = ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.7)
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
	panel.custom_minimum_size = Vector2(400, 250)
		
	center_container.add_child(panel)

	var m_container = MarginContainer.new()
	m_container.add_theme_constant_override("margin_top", 30)
	m_container.add_theme_constant_override("margin_bottom", 30)
	m_container.add_theme_constant_override("margin_left", 30)
	m_container.add_theme_constant_override("margin_right", 30)
	panel.add_child(m_container)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	m_container.add_child(vbox)
	
	var title = Label.new()
	title.text = "Custom Map Dimensions"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	if app_theme and app_theme.default_font:
		title.add_theme_font_override("font", app_theme.default_font)
	vbox.add_child(title)
	
	var sep1 = HSeparator.new()
	sep1.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(sep1)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 15)
	vbox.add_child(grid)
	
	var w_label = Label.new()
	w_label.text = "Width: "
	w_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	w_label.add_theme_font_size_override("font_size", 24)
	if app_theme and app_theme.default_font:
		w_label.add_theme_font_override("font", app_theme.default_font)
	grid.add_child(w_label)
	
	var w_hbox = HBoxContainer.new()
	var w_minus = create_styled_button("-")
	w_box = SpinBox.new()
	w_box.min_value = 40
	w_box.max_value = 1000
	w_box.step = 5
	w_box.focus_mode = Control.FOCUS_ALL
	var w_plus = create_styled_button("+")
	w_hbox.add_child(w_minus)
	w_hbox.add_child(w_box)
	w_hbox.add_child(w_plus)
	w_minus.pressed.connect(func(): w_box.value -= w_box.step)
	w_plus.pressed.connect(func(): w_box.value += w_box.step)
	grid.add_child(w_hbox)
	
	var d_label = Label.new()
	d_label.text = "Depth: "
	d_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	d_label.add_theme_font_size_override("font_size", 24)
	if app_theme and app_theme.default_font:
		d_label.add_theme_font_override("font", app_theme.default_font)
	grid.add_child(d_label)
	
	var d_hbox = HBoxContainer.new()
	var d_minus = create_styled_button("-")
	d_box = SpinBox.new()
	d_box.min_value = 40
	d_box.max_value = 1000
	d_box.step = 5
	d_box.focus_mode = Control.FOCUS_ALL
	var d_plus = create_styled_button("+")
	d_hbox.add_child(d_minus)
	d_hbox.add_child(d_box)
	d_hbox.add_child(d_plus)
	d_minus.pressed.connect(func(): d_box.value -= d_box.step)
	d_plus.pressed.connect(func(): d_box.value += d_box.step)
	grid.add_child(d_hbox)
	
	var sep2 = HSeparator.new()
	sep2.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(sep2)
	
	var h_buttons = HBoxContainer.new()
	h_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	h_buttons.add_theme_constant_override("separation", 40)
	vbox.add_child(h_buttons)
	
	var btn_confirm = create_styled_button(" Confirm ")
	btn_confirm.pressed.connect(_on_confirm)
	h_buttons.add_child(btn_confirm)
	
	var btn_cancel = create_styled_button(" Cancel ")
	btn_cancel.pressed.connect(_on_cancel)
	h_buttons.add_child(btn_cancel)
	
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

func open_modal(current_w: int, current_d: int):
	w_box.value = clamp(current_w, w_box.min_value, w_box.max_value)
	d_box.value = clamp(current_d, d_box.min_value, d_box.max_value)

	visible = true
	
	current_blocker = preload("res://mods-unpacked/Sachtleben-CustomMaps/ui/ModalBlocker.gd").new()
	current_blocker.integrate(self)
	
	w_box.get_line_edit().grab_focus()

func close_blocker():
	if current_blocker:
		InputSystem.removeProcessor(current_blocker)
		current_blocker = null

func _on_confirm():
	visible = false
	close_blocker()
	emit_signal("dimensions_confirmed", int(w_box.value), int(d_box.value))	 

func _on_cancel():
	visible = false
	close_blocker()
	emit_signal("cancelled")

