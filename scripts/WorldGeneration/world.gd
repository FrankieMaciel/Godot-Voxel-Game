extends Node3D
var chunks: Array[Chunk] = []
var temp_chunks = {}
var half_render_dis = int(Global.render_distance / 2)
var chunks_positions_to_load: Array[Vector3] = []
var task_id: int = 0

func create_chunk(chunk_index):
	var chunk_position = chunks_positions_to_load[chunk_index]
	if (chunk_position.y > Global.world_max_y): return
	if (chunk_position.y < Global.world_min_y): return
	if (chunk_position in temp_chunks): return
	var new_chunk = Chunk.new(chunk_position)
	if (new_chunk.isEmpty || new_chunk.isFull):
		temp_chunks[chunk_position] = new_chunk
		return
	var new_chunk_mesh = MeshGeneration.new(new_chunk)
	new_chunk.chunk_mesh_node = new_chunk_mesh
	Global.world_node.call_deferred_thread_group("add_child", new_chunk_mesh)
	temp_chunks[chunk_position] = new_chunk
	return
	
func load_chunks():
	for chunk in temp_chunks:
		if (chunk not in temp_chunks): continue
		if (temp_chunks[chunk] == null): continue
		else:
			if (temp_chunks[chunk].isEmpty || temp_chunks[chunk].isFull): continue
		var player_chunk_position = floor(Global.player_position / Global.chunks_size)
		var chunk_position = chunk / Global.chunks_size
		var dif = abs(player_chunk_position - chunk_position)
		if (dif.x > half_render_dis || dif.y > half_render_dis || dif.z > half_render_dis):
			temp_chunks[chunk].chunk_mesh_node.call_deferred_thread_group("queue_free")
			temp_chunks[chunk] = null
	
	if (task_id != 0):
		if (not WorkerThreadPool.is_group_task_completed(task_id)): return
	chunks_positions_to_load.clear()
	for x in range(-half_render_dis, half_render_dis):
		for z in range(-half_render_dis, half_render_dis):
			for y in range(-half_render_dis, half_render_dis):
				var chunk_pos = Vector3(x,y,z)
				var player_chunk_position = floor(Global.player_position / Global.chunks_size)
				var final_position = (player_chunk_position + chunk_pos) * Global.chunks_size
				if (final_position in temp_chunks):
					if (temp_chunks[final_position] != null): continue
				chunks_positions_to_load.append(final_position)
	print(chunks_positions_to_load.size())
	task_id = WorkerThreadPool.add_group_task(create_chunk, chunks_positions_to_load.size(), 4, true)

func _ready() -> void:
	Global.world_node = self
	
func index_to_chunk_position(index: int):
	var max_i = Global.render_distance
	var x = index / (max_i * max_i)
	var y = (index / max_i) % max_i
	var z = index % max_i
	return Vector3(x,y,z)
