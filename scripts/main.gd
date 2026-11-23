extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const MonsterScript = preload("res://scripts/monster.gd")
const DoorScript = preload("res://scripts/door.gd")
const HouseBuilder = preload("res://scripts/house_builder.gd")
const HorrorAudio = preload("res://scripts/horror_audio.gd")

var player: CharacterBody3D
var monster: CharacterBody3D
var status_label: Label
var hint_label: Label
var pause_layer: CanvasLayer
var horror_audio: Node

func _ready() -> void:
	_build_environment()
	_build_house()
	_build_hud()
	_spawn_player()
	_spawn_monster()
	horror_audio = HorrorAudio.new()
	horror_audio.name = "HorrorAudio"
	add_child(horror_audio)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.012, 0.016, 0.023)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.22, 0.25, 0.31)
	env.ambient_light_energy = 0.32
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.85
	world.environment = env
	add_child(world)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
	moon.light_color = Color(0.48, 0.57, 0.78)
	moon.light_energy = 0.22
	moon.shadow_enabled = true
	add_child(moon)

func _build_house() -> void:
	var builder = HouseBuilder.new()
	builder.build(self)
	var door := Node3D.new()
	door.name = "ExitDoor"
	door.set_script(DoorScript)
	door.position = Vector3(0, 0, 12.75)
	door.rotation.y = PI
	add_child(door)

func _add_ceiling_light(at: Vector3, energy: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = at
	lamp.light_color = Color(0.78, 0.68, 0.49)
	lamp.light_energy = energy
	lamp.omni_range = 8.0
	lamp.shadow_enabled = true
	add_child(lamp)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _make_box(label: String, at: Vector3, dimensions: Vector3, mat: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh_instance.mesh = mesh
	mesh_instance.material_override = mat
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var crosshair := Label.new()
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 22)
	crosshair.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82, 0.8))
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-6, -15)
	layer.add_child(crosshair)

	status_label = Label.new()
	status_label.position = Vector2(28, 24)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.72))
	layer.add_child(status_label)

	hint_label = Label.new()
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.position = Vector2(0, -62)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 17)
	hint_label.add_theme_color_override("font_color", Color(0.9, 0.87, 0.78))
	layer.add_child(hint_label)

func _spawn_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerScript)
	player.position = Vector3(0, 0.25, 8.0)
	add_child(player)
	player.connect("interaction_hint", Callable(self, "_on_interaction_hint"))
	player.connect("noise_emitted", Callable(self, "_on_player_noise"))

func _spawn_monster() -> void:
	monster = CharacterBody3D.new()
	monster.name = "ThePresence"
	monster.set_script(MonsterScript)
	monster.position = Vector3(-9.0, 0.05, -7.0)
	add_child(monster)
	monster.call("set_hunt_target", player)

func _process(_delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(monster):
		var distance := player.global_position.distance_to(monster.global_position)
		if is_instance_valid(horror_audio):
			horror_audio.call("set_threat", distance, int(monster.get("state")) == 2)
		status_label.text = "THE HOUSE  |  ФОНАРИК: %s  |  УГРОЗА: %s" % [
			"ВКЛ" if bool(player.get("flashlight_on")) else "ВЫКЛ",
			"РЯДОМ" if distance < 8.0 else "НЕИЗВЕСТНО"
		]

func _on_interaction_hint(message: String) -> void:
	hint_label.text = message

func _on_player_noise(origin: Vector3, loudness: float) -> void:
	if is_instance_valid(monster):
		monster.call("hear_noise", origin, loudness)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if get_tree().paused:
			_resume_game()
		else:
			_open_pause_menu()
		get_viewport().set_input_as_handled()

func _open_pause_menu() -> void:
	if is_instance_valid(pause_layer):
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	pause_layer = CanvasLayer.new()
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.layer = 30
	add_child(pause_layer)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.86)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.add_theme_constant_override("separation", 12)
	center.add_child(panel)
	var title := Label.new()
	title.text = "ПАУЗА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	panel.add_child(title)
	_pause_button(panel, "ПРОДОЛЖИТЬ", _resume_game)
	_pause_button(panel, "В ГЛАВНОЕ МЕНЮ", _return_to_menu)
	_pause_button(panel, "ВЫХОД", func(): get_tree().quit())

func _pause_button(parent: VBoxContainer, caption: String, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(340, 46)
	button.pressed.connect(action)
	parent.add_child(button)

func _resume_game() -> void:
	get_tree().paused = false
	if is_instance_valid(pause_layer):
		pause_layer.queue_free()
	pause_layer = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main.tscn")
