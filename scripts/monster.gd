extends CharacterBody3D

enum BrainState { PATROL, INVESTIGATE, CHASE, SEARCH }

const WALK_SPEED := 1.65
const CHASE_SPEED := 3.25
const GRAVITY := 18.0
const DETECT_RANGE := 12.0
const FIELD_OF_VIEW_DOT := 0.35

var target: Node3D
var state: BrainState = BrainState.PATROL
var last_known_position := Vector3.ZERO
var patrol_points: Array[Vector3] = []
var patrol_index := 0
var search_time := 0.0
var lost_sight_time := 0.0
var heard_position := Vector3.ZERO
var has_heard_noise := false

func _ready() -> void:
	_build_body()
	patrol_points = [
		Vector3(1.0, 0.1, -5.5),
		Vector3(6.5, 0.1, -5.5),
		Vector3(6.5, 0.1, 2.0),
		Vector3(4.5, 0.1, 7.0)
	]

func set_hunt_target(node: Node3D) -> void:
	target = node

func _build_body() -> void:
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 2.25
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 1.12
	add_child(collision)

	var body_mesh := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.4
	mesh.height = 2.2
	body_mesh.mesh = mesh
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.025, 0.03, 0.035)
	skin.roughness = 0.96
	body_mesh.material_override = skin
	body_mesh.position.y = 1.12
	add_child(body_mesh)

	for side in [-1.0, 1.0]:
		var eye := OmniLight3D.new()
		eye.position = Vector3(side * 0.13, 1.48, -0.31)
		eye.light_color = Color(0.8, 0.035, 0.018)
		eye.light_energy = 0.55
		eye.omni_range = 1.0
		add_child(eye)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	if _can_see_target():
		state = BrainState.CHASE
		last_known_position = target.global_position
		lost_sight_time = 0.0
	elif state == BrainState.CHASE:
		lost_sight_time += delta
		if lost_sight_time > 3.0:
			state = BrainState.SEARCH
			search_time = 5.0

	var destination := global_position
	var speed := WALK_SPEED

	match state:
		BrainState.PATROL:
			if has_heard_noise:
				state = BrainState.INVESTIGATE
				last_known_position = heard_position
				has_heard_noise = false
			else:
				destination = patrol_points[patrol_index]
				if global_position.distance_to(destination) < 0.8:
					patrol_index = (patrol_index + 1) % patrol_points.size()
		BrainState.INVESTIGATE:
			destination = last_known_position
			if global_position.distance_to(destination) < 0.9:
				state = BrainState.SEARCH
				search_time = 3.5
		BrainState.CHASE:
			destination = target.global_position
			speed = CHASE_SPEED
		BrainState.SEARCH:
			destination = last_known_position
			search_time -= delta
			if search_time <= 0.0:
				state = BrainState.PATROL

	_move_toward_point(destination, speed, delta)

func _move_toward_point(destination: Vector3, speed: float, delta: float) -> void:
	var flat_target := Vector3(destination.x, global_position.y, destination.z)
	var offset := flat_target - global_position
	if offset.length() > 0.15:
		var direction := offset.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * 2.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, speed * 2.0 * delta)

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _can_see_target() -> bool:
	var to_target := target.global_position + Vector3.UP * 1.1 - global_position - Vector3.UP * 1.2
	var distance := to_target.length()
	if distance > DETECT_RANGE:
		return false
	if distance > 0.1:
		var forward := -global_transform.basis.z
		if forward.dot(to_target.normalized()) < FIELD_OF_VIEW_DOT and distance > 3.0:
			return false
	var query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 1.4,
		target.global_position + Vector3.UP * 1.2
	)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == target

func hear_noise(origin: Vector3, loudness: float) -> void:
	if global_position.distance_to(origin) <= loudness:
		heard_position = origin
		has_heard_noise = true
		if state != BrainState.CHASE:
			state = BrainState.INVESTIGATE
			last_known_position = origin
