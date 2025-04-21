extends Node
class_name Chunk

var chunk_position: Vector3 = Vector3.ZERO
var chunk_mesh_node: Node3D
var data: Array[int] = []
var isEmpty: bool = true
var isFull: bool = false
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
	return data[(pos.x * (max_i * max_i)) + (pos.y * max_i) + pos.z];
	
func set_block_at(pos: Vector3, id: int):
	var max_i = Global.chunks_size_with_border
	data[(pos.x * (max_i * max_i)) + (pos.y * max_i) + pos.z] = id;
	
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
	if (chunk_position.y > Global.world_max_y): return
	if (chunk_position.y < Global.world_min_y): return
	if (isEmpty || isFull || hasMesh): return
	var new_chunk_mesh = MeshGeneration.new(self)
	chunk_mesh_node = new_chunk_mesh
	hasMesh = true
	Global.world_node.call_deferred_thread_group("add_child", new_chunk_mesh)
	
func remove_mesh():
	if (not hasMesh): return
	chunk_mesh_node.call_deferred_thread_group("queue_free")
	hasMesh = false

func hide_mesh():
	if (not hasMesh): return
	chunk_mesh_node.visible = false
	
func show_mesh():
	if (not hasMesh): return
	chunk_mesh_node.visible = true
