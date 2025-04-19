extends Node3D
var chunks: Array[Chunk] = []

func create_chunk(chunk_index):
	var chunk_position = index_to_chunk_position(chunk_index) * Global.chunks_size
	var new_chunk = Chunk.new(chunk_position)
	if (new_chunk.isEmpty || new_chunk.isFull): return
	var new_chunk_mesh = MeshGeneration.new(new_chunk)
	Global.world_node.call_deferred_thread_group("add_child", new_chunk_mesh)
	#chunks.append(new_chunk)

func _ready() -> void:
	Global.world_node = self
	WorkerThreadPool.add_group_task(create_chunk, Global.render_distance**3, 4, true)
	#WorkerThreadPool.wait_for_group_task_completion(task_id)
	print(len(chunks))
	
func index_to_chunk_position(index: int):
	var max_i = Global.render_distance
	var x = index / (max_i * max_i)
	var y = (index / max_i) % max_i
	var z = index % max_i
	return Vector3(x,y,z)
