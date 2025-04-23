extends Node
class_name Chunk

var chunk_position: Vector3 = Vector3.ZERO
var chunk_mesh_node: MeshGeneration
var data: Array[int] = []
var isEmpty: bool = true
var isFull: bool = true
var wasModified: bool = false
var hasMesh = false

var generateChunk = null

func _init(chunks_pos: Vector3):
	chunk_position = chunks_pos
	data.resize(Global.chunks_size_with_border**3)
	data.fill(0)
	generateChunk = ChunkGeneration.new(self)
	
func get_block_at(pos: Vector3):
	var max_i = Global.chunks_size_with_border
	var index = (pos.x * (max_i * max_i)) + (pos.y * max_i) + pos.z
	if (index >= len(data)): return
	return data[index];
	
func set_block_at(pos: Vector3, id: int):
	var max_i = Global.chunks_size_with_border
	var index = (pos.x * (max_i * max_i)) + (pos.y * max_i) + pos.z
	if (index >= len(data)): return
	if (id != 0): isEmpty = false
	data[index] = id;
	
func index_to_coordinates3D(index):
	var max_i = Global.chunks_size_with_border
	var x = index / (max_i * max_i)
	var y = (index / max_i) % max_i
	var z = index % max_i
	return Vector3(x,y,z)

func is_on_chunk_border(block_position: Vector3):
	var xCheck = block_position.x == 0 || block_position.x == Global.chunks_size_with_border - 1
	var yCheck = block_position.y == 0 || block_position.y == Global.chunks_size_with_border - 1
	var zCheck = block_position.z == 0 || block_position.z == Global.chunks_size_with_border - 1
	return xCheck || yCheck || zCheck
	
func create_mesh():
	remove_mesh()
	if (chunk_position.y > Global.world_max_y): return
	if (chunk_position.y < Global.world_min_y): return
	if (isEmpty || isFull || hasMesh): return
	chunk_mesh_node = MeshGeneration.new(self)
	hasMesh = true
	Global.world_node.call_deferred_thread_group("add_child", chunk_mesh_node)
	
func remove_mesh():
	if (not hasMesh): return
	hide_mesh()
	chunk_mesh_node.collission_ref.disabled = true
	Global.world_node.mesh_to_free.append(chunk_mesh_node)
	hasMesh = false

func hide_mesh():
	if (not hasMesh): return
	chunk_mesh_node.visible = false
	
func show_mesh():
	if (not hasMesh): return
	chunk_mesh_node.visible = true
	
