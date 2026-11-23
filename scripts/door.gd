extends Node3D

var is_open := false
var closed_rotation := 0.0
var open_rotation := deg_to_rad(96.0)

func _ready() -> void:
	name = "ExitDoor"
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.16, 0.085, 0.045)
	wood.roughness = 0.68

	var panel := StaticBody3D.new()
	panel.name = "DoorPanel"
	panel.position = Vector3(0, 1.2, 0)
	add_child(panel)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 2.4, 0.16)
	mesh_instance.mesh = mesh
	mesh_instance.material_override = wood
	panel.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 2.4, 0.16)
	collision.shape = shape
	panel.add_child(collision)

	var knob := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.075
	sphere.height = 0.15
	knob.mesh = sphere
	var brass := StandardMaterial3D.new()
	brass.albedo_color = Color(0.55, 0.37, 0.12)
	knob.material_override = brass
	knob.position = Vector3(0.72, 0.0, -0.11)
	panel.add_child(knob)

func get_interaction_text() -> String:
	return "[E] Открыть дверь" if not is_open else "[E] Закрыть дверь"

func interact() -> void:
	is_open = not is_open
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation:y", open_rotation if is_open else closed_rotation, 0.55)
