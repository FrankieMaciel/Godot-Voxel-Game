extends MeshInstance3D
class_name MeshGeneration

var cgp: Vector3
var spatialMaterial : StandardMaterial3D = preload("res://Materials/chunk_material.tres")

func _init(chunk: Chunk) -> void:
	connect("tree_entered", add_position_offset)
	cgp = chunk.chunk_position
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var countFaces = [0,0,0,0,0,0]
	var init_vec = Vector3(1,1,1)
	var faces_positions = [init_vec,init_vec,init_vec,init_vec,init_vec,init_vec]
	for index in range(len(chunk.data)):
		var block_coords = chunk.index_to_coordinates3D(index)
		if (chunk.is_on_chunk_border(block_coords)):
			for side_idx in range(len(countFaces)):
				if (countFaces[side_idx] > 0):
					create_block(st, faces_positions[side_idx], Global.indeces_to_directions[side_idx], countFaces[side_idx])
			countFaces = [0,0,0,0,0,0]
			faces_positions = [init_vec,init_vec,init_vec,init_vec,init_vec,init_vec]
			continue
		if (chunk.data[index] == 0):
			for side_idx in range(len(countFaces)):
				if (countFaces[side_idx] > 0): 
					create_block(st, faces_positions[side_idx], Global.indeces_to_directions[side_idx], countFaces[side_idx])
			countFaces = [0,0,0,0,0,0]
			faces_positions = [init_vec,init_vec,init_vec,init_vec,init_vec,init_vec]
			continue
		for side in Global.directions:
			var dir_idx = Global.directions_indeces[side]
			if (chunk.get_block_at(block_coords + Global.directions[side]) == 0):
				if (countFaces[dir_idx] == 0): faces_positions[dir_idx] = block_coords
				countFaces[dir_idx] += 1
			elif (countFaces[dir_idx] > 0): 
				create_block(st, faces_positions[dir_idx], side, countFaces[dir_idx])
				countFaces[dir_idx] = 0
				faces_positions[dir_idx] = init_vec
	mesh = st.commit()
	var static_body = StaticBody3D.new()
	var collision = CollisionShape3D.new()
	collision.shape = mesh.create_trimesh_shape()
	static_body.add_child(collision)
	add_child(static_body)
	material_override = spatialMaterial
	
func create_block(st: SurfaceTool, offset: Vector3, direction: String, size: int):
	offset -= Vector3(1,0,1)
	var a := Vector3(0, 1, 0) + offset
	var b := Vector3(1, 1, 0) + offset
	var c := Vector3(1, 0, 0) + offset
	var d := Vector3(0, 0, 0) + offset
	var e := Vector3(0, 1, 1 * size) + offset
	var f := Vector3(1, 1, 1 * size) + offset
	var g := Vector3(1, 0, 1 * size) + offset
	var h := Vector3(0, 0, 1 * size) + offset

	var vertices := [ 		# faces (triangles)
		[a,b,f,  a,f,e],  	# Up
		[h,g,c,  h,c,d],  	# Down
		[f,b,c,  f,c,g],  	# Left
		[a,e,h,  a,h,d],  	# Rigth
		[e,f,g,  e,g,h],  	# Front
		[b,a,d,  b,d,c],  	# Back
	]
	var UVs : Array = [
		Vector2(0,0),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,0),
		Vector2(1,1),
		Vector2(0,1)
	]
	var side_normal = abs(Global.directions[direction])
	var uv_vec = Vector2(1,1)
	var max_idx = side_normal.max_axis_index()
	if max_idx == 2: max_idx = 0
	uv_vec[max_idx] = size
	var i = Global.directions_indeces[direction]
	for v in range(6):
		st.set_normal(Global.directions[direction])
		st.set_uv(UVs[v] * uv_vec)
		st.add_vertex(vertices[i][v])

func add_position_offset() -> void:
	global_position = cgp
	pass # Replace with function body.
