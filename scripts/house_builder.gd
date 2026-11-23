extends RefCounted
## Procedural environment art pass. All dimensions are metres.

var root: Node3D
var mats := {}

func build(parent: Node3D) -> void:
	root = parent
	mats["plaster"] = _mat(Color(0.31,0.285,0.245),0.92)
	mats["plaster_dark"] = _mat(Color(0.105,0.095,0.083),0.94)
	mats["oak"] = _mat(Color(0.16,0.075,0.035),0.62)
	mats["oak_light"] = _mat(Color(0.29,0.16,0.075),0.58)
	mats["floor"] = _mat(Color(0.19,0.12,0.075),0.48)
	mats["metal"] = _mat(Color(0.075,0.08,0.085),0.28,0.75)
	mats["fabric"] = _mat(Color(0.19,0.055,0.045),0.98)
	mats["dust"] = _mat(Color(0.23,0.22,0.19),1.0)
	mats["glass"] = _emissive(Color(0.11,0.17,0.22),Color(0.12,0.2,0.28),0.45)
	_build_shell()
	_build_foyer()
	_build_salon()
	_build_dining_room()
	_build_kitchen()
	_build_library()
	_build_bedroom()
	_build_basement_stairs()
	_build_lighting()

func _mat(color: Color, rough: float, metal: float = 0.0) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new()
	m.albedo_color=color
	m.roughness=rough
	m.metallic=metal
	return m

func _emissive(color: Color, glow: Color, energy: float) -> StandardMaterial3D:
	var m:=_mat(color,0.25)
	m.emission_enabled=true
	m.emission=glow
	m.emission_energy_multiplier=energy
	return m

func _box(label: String, pos: Vector3, size: Vector3, material: Material, solid: bool = true) -> Node3D:
	var host: Node3D
	if solid:
		var body:=StaticBody3D.new()
		body.name=label
		host=body
		var collision:=CollisionShape3D.new()
		var shape:=BoxShape3D.new()
		shape.size=size
		collision.shape=shape
		body.add_child(collision)
	else:
		host=Node3D.new()
		host.name=label
	var mesh:=MeshInstance3D.new()
	var box:=BoxMesh.new()
	box.size=size
	mesh.mesh=box
	mesh.material_override=material
	host.add_child(mesh)
	host.position=pos
	root.add_child(host)
	return host

func _cylinder(label: String,pos: Vector3,radius: float,height: float,material: Material) -> void:
	var body:=StaticBody3D.new()
	body.name=label
	body.position=pos
	var mesh:=MeshInstance3D.new()
	var shape_mesh:=CylinderMesh.new()
	shape_mesh.top_radius=radius
	shape_mesh.bottom_radius=radius
	shape_mesh.height=height
	mesh.mesh=shape_mesh
	mesh.material_override=material
	body.add_child(mesh)
	var collision:=CollisionShape3D.new()
	var shape:=CylinderShape3D.new()
	shape.radius=radius
	shape.height=height
	collision.shape=shape
	body.add_child(collision)
	root.add_child(body)

func _wall(pos: Vector3,size: Vector3) -> void:
	_box("Plaster wall",pos,size,mats["plaster"])
	_box("Dark skirting",Vector3(pos.x,pos.y-size.y*0.5+0.12,pos.z),Vector3(size.x,0.24,size.z+0.02),mats["oak"],false)

func _shell_room(cx: float,cz: float,w: float,d: float,doors: Array[String]=[]) -> void:
	_box("Oak floor",Vector3(cx,0,cz),Vector3(w,0.22,d),mats["floor"])
	_box("Ceiling",Vector3(cx,3.55,cz),Vector3(w,0.18,d),mats["plaster_dark"])
	var t:=0.28
	for x in [-w/2+0.2,w/2-0.2]:
		_box("Crown moulding",Vector3(cx+x,3.35,cz),Vector3(0.12,0.16,d),mats["oak_light"],false)

func _table(pos: Vector3,w: float,d: float,h: float) -> void:
	_box("Table top",pos+Vector3(0,h,0),Vector3(w,0.14,d),mats["oak_light"])
	for x in [-w*0.42,w*0.42]:
		for z in [-d*0.4,d*0.4]:
			_box("Turned table leg",pos+Vector3(x,h*0.5,z),Vector3(0.13,h,0.13),mats["oak"])

func _chair(pos: Vector3) -> void:
	_box("Chair seat",pos+Vector3(0,0.52,0),Vector3(0.72,0.12,0.68),mats["oak_light"])
	_box("Chair back",pos+Vector3(0,0.95,0.29),Vector3(0.72,0.82,0.12),mats["oak"])
	for x in [-0.28,0.28]:
		for z in [-0.24,0.24]:
			_box("Chair leg",pos+Vector3(x,0.25,z),Vector3(0.09,0.5,0.09),mats["oak"])

func _cabinet(pos: Vector3,w: float,h: float,d: float) -> void:
	_box("Cabinet carcass",pos+Vector3(0,h/2,0),Vector3(w,h,d),mats["oak"])
	for x in [-w*0.24,w*0.24]:
		_box("Cabinet door",pos+Vector3(x,h*0.52,-d*0.51),Vector3(w*0.46,h*0.88,0.06),mats["oak_light"])
		_cylinder("Brass handle",pos+Vector3(x+0.11,h*0.52,-d*0.56),0.035,0.08,mats["metal"])

func _window(pos: Vector3,w: float,h: float) -> void:
	_box("Window glass",pos,Vector3(w,h,0.08),mats["glass"],false)
	_box("Window left frame",pos+Vector3(-w/2,0,0),Vector3(0.13,h+0.2,0.18),mats["oak_light"],false)
	_box("Window right frame",pos+Vector3(w/2,0,0),Vector3(0.13,h+0.2,0.18),mats["oak_light"],false)
	_box("Window sill",pos+Vector3(0,-h/2,0),Vector3(w+0.2,0.14,0.28),mats["oak_light"],false)
	_box("Window crossbar",pos,Vector3(w,0.09,0.16),mats["oak_light"],false)

func _lamp(pos: Vector3,color: Color,energy: float,range_value: float) -> void:
	_box("Ceiling rose",pos+Vector3(0,0.06,0),Vector3(0.32,0.08,0.32),mats["metal"],false)
	var light:=OmniLight3D.new()
	light.position=pos+Vector3(0,-0.25,0)
	light.light_color=color
	light.light_energy=energy
	light.omni_range=range_value
	light.shadow_enabled=true
	root.add_child(light)

func _build_shell() -> void:
	# Ground-floor interconnected footprint: foyer, salon, dining room, kitchen, library and corridor.
	_shell_room(0,8,12,10)
	_shell_room(-9,7,7,10)
	_shell_room(0,-1,12,8)
	_shell_room(9,-1,7,8)
	_shell_room(-9,-5,7,8)
	_shell_room(0,-9,12,8)
	# Exterior perimeter. Interior rooms remain connected through broad door openings.
	_wall(Vector3(-12.5,1.75,0),Vector3(0.28,3.4,27))
	_wall(Vector3(12.5,1.75,0),Vector3(0.28,3.4,27))
	_wall(Vector3(0,1.75,-13.5),Vector3(25.3,3.4,0.28))
	_wall(Vector3(0,1.75,13.5),Vector3(25.3,3.4,0.28))
	# Interior partitions guide sightlines but leave traversable openings.
	_wall(Vector3(-6,1.75,8),Vector3(0.25,3.4,6.0))
	_wall(Vector3(6,1.75,8),Vector3(0.25,3.4,6.0))
	_wall(Vector3(-9,1.75,2),Vector3(7,3.4,0.25))
	_wall(Vector3(9,1.75,2),Vector3(7,3.4,0.25))
	_wall(Vector3(-9,1.75,-1),Vector3(7,3.4,0.25))
	_wall(Vector3(9,1.75,-5),Vector3(7,3.4,0.25))
	_wall(Vector3(0,1.75,-5),Vector3(0.25,3.4,8))

func _build_foyer() -> void:
	_box("Foyer runner rug",Vector3(0,0.14,8),Vector3(3.4,0.035,6.2),mats["fabric"],false)
	_cabinet(Vector3(-4.6,0,10.5),1.8,1.8,0.65)
	_box("Foyer mirror",Vector3(-4.55,2.35,10.12),Vector3(1.2,1.5,0.08),mats["metal"],false)
	_box("Mirror reflection",Vector3(-4.55,2.35,10.06),Vector3(1.02,1.32,0.025),mats["glass"],false)
	_table(Vector3(0,0,7.2),1.3,1.3,0.78)
	_cylinder("Vase",Vector3(0,1.08,7.2),0.18,0.5,mats["metal"])
	_window(Vector3(0,2.1,12.8),2.2,2.1)

func _build_salon() -> void:
	_box("Salon rug",Vector3(-9,0.14,7),Vector3(4.8,0.04,5.5),mats["fabric"],false)
	_box("Sofa base",Vector3(-9,0.55,4.6),Vector3(3.4,0.55,1.1),mats["fabric"])
	_box("Sofa back",Vector3(-9,1.05,5.05),Vector3(3.4,1.0,0.28),mats["fabric"])
	for x in [-10.2,-9,-7.8]:
		_box("Sofa cushion",Vector3(x,0.91,4.55),Vector3(1.0,0.2,0.82),mats["oak_light"],false)
	_table(Vector3(-9,0,8),2.4,1.2,0.52)
	_cabinet(Vector3(-11.7,0,9.6),1.1,1.5,0.7)
	_window(Vector3(-9,2.0,12.1),2.6,1.8)

func _build_dining_room() -> void:
	_table(Vector3(0,0,-1),4.0,1.6,0.82)
	for x in [-1.4,1.4]:
		for z in [-2.5,0.5]:
			_chair(Vector3(x,0,z))
	_box("Dining chandelier",Vector3(0,3.0,-1),Vector3(0.18,0.8,0.18),mats["metal"],false)
	_lamp(Vector3(0,2.65,-1),Color(1.0,0.73,0.44),1.25,8.5)
	_cabinet(Vector3(4.4,0,-2.9),2.2,1.5,0.65)

func _build_kitchen() -> void:
	for x in [7.0,8.8,10.6]:
		_box("Kitchen lower cabinet",Vector3(x,0.48,-3.6),Vector3(1.65,0.96,0.82),mats["oak"])
		_box("Stone countertop",Vector3(x,1.02,-3.6),Vector3(1.72,0.12,0.9),mats["dust"])
		_box("Upper cabinet",Vector3(x,2.45,-4.0),Vector3(1.5,1.0,0.5),mats["oak_light"])
	_box("Kitchen island",Vector3(9,0.55,-0.2),Vector3(3.0,1.1,1.4),mats["oak"])
	_box("Island stone top",Vector3(9,1.14,-0.2),Vector3(3.1,0.12,1.5),mats["dust"])
	_cylinder("Old pot",Vector3(9.4,1.4,-0.2),0.28,0.35,mats["metal"])
	_window(Vector3(9,2.0,-5.0),2.0,1.5)

func _build_library() -> void:
	for z in [-7.4,-5.0,-2.6]:
		_box("Library bookcase",Vector3(-11.6,1.45,z),Vector3(0.65,2.9,2.1),mats["oak"])
		for y in [0.65,1.35,2.05]:
			_box("Bookshelf",Vector3(-11.22,y,z),Vector3(0.12,0.08,1.95),mats["oak_light"],false)
			for i in range(7):
				var book_mat:=_mat([Color(0.18,0.035,0.025),Color(0.08,0.13,0.12),Color(0.22,0.16,0.09)][i%3],0.9)
				_box("Old book",Vector3(-11.12,y+0.18,z-0.78+i*0.24),Vector3(0.22,0.36,0.17),book_mat,false)
	_table(Vector3(-8.8,0,-5),1.8,1.0,0.74)
	_chair(Vector3(-8.8,0,-6.2))

func _build_bedroom() -> void:
	_box("Bedroom bed frame",Vector3(0,0.45,-10),Vector3(3.0,0.8,4.0),mats["oak"])
	_box("Mattress",Vector3(0,0.98,-10),Vector3(2.85,0.32,3.85),mats["dust"])
	_box("Blanket",Vector3(0,1.18,-10.7),Vector3(2.88,0.16,2.3),mats["fabric"])
	for x in [-0.8,0.8]:
		_box("Pillow",Vector3(x,1.23,-8.65),Vector3(0.9,0.18,0.7),mats["dust"],false)
	_cabinet(Vector3(-4.8,0,-11.7),1.6,2.2,0.8)
	_box("Bedroom wardrobe",Vector3(4.8,1.4,-11.5),Vector3(1.5,2.8,1.0),mats["oak"])
	_window(Vector3(0,2.0,-13.1),2.4,1.8)

func _build_basement_stairs() -> void:
	# A visible stairwell opening and descending steps establish the next playable area.
	for i in range(9):
		_box("Basement stair %02d"%i,Vector3(5.0,1.55-i*0.17,-7.0-i*0.42),Vector3(2.2,0.18,0.48),mats["oak_light"])
	_box("Basement darkness",Vector3(5.0,-0.15,-11.3),Vector3(5.5,0.2,4.0),mats["plaster_dark"])

func _build_lighting() -> void:
	_lamp(Vector3(0,3.2,8),Color(1.0,0.76,0.52),1.2,10)
	_lamp(Vector3(-9,3.2,7),Color(0.88,0.72,0.52),0.8,8)
	_lamp(Vector3(0,3.2,-1),Color(1.0,0.72,0.46),1.0,8)
	_lamp(Vector3(9,3.2,-1),Color(0.72,0.78,0.92),0.55,7)
	_lamp(Vector3(-9,3.2,-5),Color(0.78,0.83,1.0),0.45,7)
	_lamp(Vector3(0,3.2,-9),Color(0.9,0.68,0.45),0.7,8)
