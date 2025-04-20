extends MeshInstance3D
class_name MeshGeneration

var cgp: Vector3
var spatialMaterial : StandardMaterial3D = preload("res://Materials/chunk_material.tres")

func _init(chunk: Chunk) -> void:
	connect("tree_entered", add_position_offset)
	cgp = chunk.chunk_position
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(len(chunk.data)):
		if (chunk.data[index] == 0): continue
		var block_coords = chunk.index_to_coordinates3D(index)
		if (chunk.is_on_chunk_border(block_coords)): continue
		if (chunk.get_block_at(block_coords + Global.directions["up"]) == 0):
			create_block(st, block_coords, "up")
		if (chunk.get_block_at(block_coords + Global.directions["down"]) == 0): 
			create_block(st, block_coords, "down")
		if (chunk.get_block_at(block_coords + Global.directions["left"]) == 0): 
			create_block(st, block_coords, "left")
		if (chunk.get_block_at(block_coords + Global.directions["right"]) == 0): 
			create_block(st, block_coords, "right")
		if (chunk.get_block_at(block_coords + Global.directions["front"]) == 0):
			create_block(st, block_coords, "front")
		if (chunk.get_block_at(block_coords + Global.directions["back"]) == 0): 
			create_block(st, block_coords, "back")
	mesh = st.commit()
	var static_body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision)
	add_child(static_body)
	material_override = spatialMaterial
	
func create_block(st: SurfaceTool, offset: Vector3, direction: String):
	offset -= Vector3(1,0,1)
	var a := Vector3(0, 1, 0) + offset
	var b := Vector3(1, 1, 0) + offset
	var c := Vector3(1, 0, 0) + offset
	var d := Vector3(0, 0, 0) + offset
	var e := Vector3(0, 1, 1) + offset
	var f := Vector3(1, 1, 1) + offset
	var g := Vector3(1, 0, 1) + offset
	var h := Vector3(0, 0, 1) + offset

	var vertices := [ 		# faces (triangles)
		[a,b,f,  a,f,e],  	# Up
		[h,g,c,  h,c,d],  	# Down
		[f,b,c,  f,c,g],  	# Left
		[a,e,h,  a,h,d],  	# Rigth
		[e,f,g,  e,g,h],  	# Front
		[b,a,d,  b,d,c],  	# Back
	]
	const UVs : Array = [
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,0),
		Vector2(1,1),
		Vector2(0,1)
	]
	var i = Global.directions_indeces[direction]
	for v in range(6):
		st.set_normal(Global.directions[direction])
		st.set_uv(UVs[v])
		st.add_vertex(vertices[i][v])

func add_position_offset() -> void:
	global_position = cgp
	pass # Replace with function body.
