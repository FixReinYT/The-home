extends CharacterBody3D

enum BrainState { PATROL, INVESTIGATE, CHASE, SEARCH }

const WALK_SPEED := 1.65
const CHASE_SPEED := 3.25
const GRAVITY := 18.0
const DETECT_RANGE := 8.5
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
	capsule.radius = 0.36
	capsule.height = 2.15
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = 1.08
	add_child(collision)

	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.045, 0.038, 0.035)
	skin.roughness = 0.98
	skin.metallic = 0.0
	var wet_skin := StandardMaterial3D.new()
	wet_skin.albedo_color = Color(0.09, 0.075, 0.068)
	wet_skin.roughness = 0.72

	_add_capsule_part("Torso", Vector3(0,1.18,0), 0.34, 0.82, skin)
	_add_sphere_part("Head", Vector3(0,1.88,-0.015), Vector3(0.29,0.37,0.27), wet_skin)
	_add_capsule_part("Neck", Vector3(0,1.62,0), 0.13, 0.28, skin)
	for side in [-1.0,1.0]:
		_add_capsule_part("Long arm", Vector3(side*0.43,1.12,0.015), 0.105, 0.88, skin, Vector3(0,0,side*0.10))
		_add_capsule_part("Long leg", Vector3(side*0.17,0.43,0.015), 0.14, 0.82, skin)
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.045
		eye_mesh.height = 0.09
		eye.mesh = eye_mesh
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.8,0.018,0.008)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.85,0.015,0.005)
		eye_mat.emission_energy_multiplier = 1.8
		eye.material_override = eye_mat
		eye.position = Vector3(side*0.105,1.92,-0.255)
		add_child(eye)

func _add_capsule_part(label: String, at: Vector3, radius: float, height: float, material: Material, tilt: Vector3 = Vector3.ZERO) -> void:
	var part := MeshInstance3D.new()
	part.name = label
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	part.mesh = mesh
	part.material_override = material
	part.position = at
	part.rotation = tilt
	add_child(part)

func _add_sphere_part(label: String, at: Vector3, dimensions: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	part.name = label
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	part.mesh = mesh
	part.scale = dimensions
	part.material_override = material
	part.position = at
	add_child(part)

