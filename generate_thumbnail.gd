extends SceneTree

func _init():
	var vp = SubViewport.new()
	vp.size = Vector2(512, 512)
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	self.root.add_child(vp)
	
	var bg = ColorRect.new()
	bg.color = Color("#111116")
	bg.size = Vector2(512, 512)
	vp.add_child(bg)
	
	var map_img = Image.new()
	if map_img.load("res://content/icons/stationextensionminimap.png") == OK:
		var replace1 = Color("#106ef0")
		var replace2 = Color("#084bf0")
		
		for y in range(map_img.get_height()):
			for x in range(map_img.get_width()):
				var c = map_img.get_pixel(x, y)
				if c.is_equal_approx(replace1) or c.is_equal_approx(replace2):
					map_img.set_pixel(x, y, Color(0,0,0,0))
				else:
					var gray = c.r * 0.299 + c.g * 0.587 + c.b * 0.114
					# Boost contrast to make the paper borders and folds more defined!
					gray = clamp((gray - 0.2) * 1.5 + 0.3, 0.0, 1.0)
					var gold = Color("#e5bc6e")
					var new_c = Color(gray * gold.r, gray * gold.g, gray * gold.b, c.a).lightened(0.15)
					map_img.set_pixel(x, y, new_c)
					
		var icon_tex = ImageTexture.create_from_image(map_img)
		
		var main_icon = Sprite2D.new()
		main_icon.texture = icon_tex
		main_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		main_icon.position = Vector2(256, 170)
		main_icon.scale = Vector2(8, 8)
		vp.add_child(main_icon)
	
	var title = Label.new()
	title.text = "CUSTOM MAPS"
	var title_font = load("res://gui/fonts/FontHeading.tres")
	if title_font:
		title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 64)
	var title_c = Color("#fadd68")
	title.add_theme_color_override("font_color", title_c)
	title.add_theme_color_override("font_outline_color", title_c)
	title.add_theme_constant_override("outline_size", 3)
	title.add_theme_constant_override("line_spacing", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 355)
	title.size = Vector2(512, 100)
	vp.add_child(title)
	
	var author = Label.new()
	author.text = "SACHTLEBEN"
	var p_font = load("res://gui/fonts/FontHeading.tres")
	if p_font:
		author.add_theme_font_override("font", p_font)
	author.add_theme_font_size_override("font_size", 34)
	author.add_theme_color_override("font_color", Color("#9d8f9f"))
	author.add_theme_color_override("font_outline_color", Color(0,0,0,0))
	author.add_theme_constant_override("outline_size", 0)
	author.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	author.position = Vector2(0, 425)
	author.size = Vector2(512, 100)
	vp.add_child(author)

	for i in range(5):
		await process_frame
		
	var img = vp.get_texture().get_image()
	img.save_png("res://mods-unpacked/Sachtleben-CustomMaps/preview.png")
	
	print("---------------------------------------------------")
	print("SUCCESS: Final Thumbnail generated to mods-unpacked/Sachtleben-CustomMaps/preview.png")
	print("---------------------------------------------------")
	quit()
