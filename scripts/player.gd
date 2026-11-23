extends CharacterBody3D

signal noise_emitted(origin: Vector3, loudness: float)
signal interaction_hint(message: String)

const WALK_SPEED := 3.0
const RUN_SPEED := 5.2
const CROUCH_SPEED := 1.65
const MOUSE_SENSITIVITY := 0.0018
const GRAVITY := 18.0

var camera: Camera3D
var ray: RayCast3D
var flashlight: SpotLight3D
var flashlight_on := true
var noise_clock := 0.0
var current_hint := ""

func _ready() -> void:
	_configure_input()
	add_to_group("player")
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.75
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 0.88
	add_child(collision)

	camera = Camera3D.new()
	camera.position = Vector3(0, 1.58, 0)
	camera.fov = 78.0
	add_child(camera)

	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -2.6)
	ray.enabled = true
	camera.add_child(ray)

	flashlight = SpotLight3D.new()
	flashlight.position = Vector3(0.16, -0.12, -0.12)
	flashlight.light_color = Color(0.82, 0.88, 1.0)
	flashlight.light_energy = 3.2
	flashlight.spot_range = 19.0
	flashlight.spot_angle = 34.0
	flashlight.shadow_enabled = true
	camera.add_child(flashlight)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-82), deg_to_rad(82))
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("interact"):
		_interact()
	if event.is_action_pressed("flashlight"):
		flashlight_on = not flashlight_on
		flashlight.visible = flashlight_on

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var input_vector := Vector2.ZERO
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	var crouching := Input.is_action_pressed("crouch")
	var running := Input.is_action_pressed("run") and not crouching
	var speed := CROUCH_SPEED if crouching else (RUN_SPEED if running else WALK_SPEED)
	var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	if direction.length() > 0.05:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED * 5.0 * delta)

	move_and_slide()

	if direction.length() > 0.05 and running:
		noise_clock += delta
		if noise_clock >= 0.7:
			noise_clock = 0.0
			noise_emitted.emit(global_position, 13.0)
	elif direction.length() > 0.05 and not crouching:
		noise_clock += delta
		if noise_clock >= 1.15:
			noise_clock = 0.0
			noise_emitted.emit(global_position, 6.0)

	_update_interaction_hint()

func _interact() -> void:
	ray.force_raycast_update()
	if ray.is_colliding():
		var target: Object = ray.get_collider()
		if target and not target.has_method("interact"):
			target = (target as Node).get_parent()
		if target and target.has_method("interact"):
			target.interact()

func _update_interaction_hint() -> void:
	ray.force_raycast_update()
	var next_hint := ""
	if ray.is_colliding():
		var target: Object = ray.get_collider()
		if target and not target.has_method("get_interaction_text"):
			target = (target as Node).get_parent()
		if target and target.has_method("get_interaction_text"):
			next_hint = target.get_interaction_text()
	if next_hint != current_hint:
		current_hint = next_hint
		interaction_hint.emit(current_hint)

func _configure_input() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("run", KEY_SHIFT)
	_add_key_action("crouch", KEY_CTRL)
	_add_key_action("interact", KEY_E)
	_add_key_action("flashlight", KEY_F)

func _add_key_action(action_name: String, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = key_code
	InputMap.action_add_event(action_name, event)
