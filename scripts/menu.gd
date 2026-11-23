extends Control

const GAME_SCENE := "res://scenes/game.tscn"
const SETTINGS_PATH := "user://settings.cfg"
var settings := ConfigFile.new()
var content: VBoxContainer

func _ready() -> void:
	settings.load(SETTINGS_PATH)
	_apply_settings()
	var bg := ColorRect.new()
	bg.color = Color(0.012, 0.016, 0.022)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var vignette := ColorRect.new()
	vignette.color = Color(0.0, 0.0, 0.0, 0.38)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vignette)
	_show_main()

func _layout() -> VBoxContainer:
	if is_instance_valid(content):
		content.get_parent().queue_free()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(420, 0)
	content.add_theme_constant_override("separation", 12)
	center.add_child(content)
	return content

func _heading(title_text: String, subtitle: String = "") -> void:
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", Color(0.91, 0.88, 0.82))
	content.add_child(title)
	if subtitle != "":
		var sub := Label.new()
		sub.text = subtitle
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.add_theme_font_size_override("font_size", 13)
		sub.add_theme_color_override("font_color", Color(0.58, 0.57, 0.54))
		content.add_child(sub)

func _add_button(caption: String, action: Callable) -> void:
	var b := Button.new()
	b.text = caption
	b.custom_minimum_size = Vector2(380, 48)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 17)
	b.pressed.connect(action)
	content.add_child(b)

func _show_main() -> void:
	_layout()
	_heading("THE HOUSE", "A PSYCHOLOGICAL HORROR EXPERIENCE")
	var gap := Control.new()
	gap.custom_minimum_size.y = 22
	content.add_child(gap)
	_add_button("НОВАЯ ИГРА", _start_game)
	_add_button("ПРОДОЛЖИТЬ", func(): _notice("Система сохранений пока не реализована."))
	_add_button("ЗАГРУЗИТЬ ИГРУ", func(): _notice("Слоты сохранений появятся после реализации сохранений."))
	_add_button("НАСТРОЙКИ", _show_settings)
	_add_button("АВТОРЫ", _show_credits)
	_add_button("ВЫХОД", func(): get_tree().quit())
	var version := Label.new()
	version.text = "EARLY DEVELOPMENT BUILD"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size", 11)
	version.add_theme_color_override("font_color", Color(0.42, 0.42, 0.40))
	content.add_child(version)

func _show_settings() -> void:
	_layout()
	_heading("НАСТРОЙКИ", "ИЗОБРАЖЕНИЕ И ЗВУК")
	var resolution_label := Label.new()
	resolution_label.text = "Разрешение"
	content.add_child(resolution_label)
	var resolution := OptionButton.new()
	var sizes := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
	for size in sizes:
		resolution.add_item("%d × %d" % [size.x, size.y])
	var saved: Vector2i = settings.get_value("display", "resolution", Vector2i(1280, 720))
	for i in range(sizes.size()):
		if sizes[i] == saved:
			resolution.select(i)
	content.add_child(resolution)
	var fullscreen := CheckBox.new()
	fullscreen.text = "Полноэкранный режим"
	fullscreen.button_pressed = bool(settings.get_value("display", "fullscreen", false))
	content.add_child(fullscreen)
	var volume_label := Label.new()
	volume_label.text = "Громкость"
	content.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = 0
	volume.max_value = 100
	volume.step = 1
	volume.value = float(settings.get_value("audio", "volume", 80))
	content.add_child(volume)
	_add_button("ПРИМЕНИТЬ", func():
		settings.set_value("display", "resolution", sizes[resolution.selected])
		settings.set_value("display", "fullscreen", fullscreen.button_pressed)
		settings.set_value("audio", "volume", volume.value)
		settings.save(SETTINGS_PATH)
		_apply_settings()
		_notice("Настройки сохранены.")
	)
	_add_button("НАЗАД", _show_main)

func _apply_settings() -> void:
	var full := bool(settings.get_value("display", "fullscreen", false))
	var size: Vector2i = settings.get_value("display", "resolution", Vector2i(1280, 720))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if full else DisplayServer.WINDOW_MODE_WINDOWED)
	if not full:
		DisplayServer.window_set_size(size)
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		var v := float(settings.get_value("audio", "volume", 80)) / 100.0
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(v, 0.001)))

func _show_credits() -> void:
	_layout()
	_heading("АВТОРЫ")
	var label := Label.new()
	label.text = "THE HOUSE\nIndependent horror game project\n\nРазработка: FixReinYT"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(label)
	_add_button("НАЗАД", _show_main)

func _notice(message: String) -> void:
	_layout()
	_heading("THE HOUSE", message)
	_add_button("НАЗАД", _show_main)

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
