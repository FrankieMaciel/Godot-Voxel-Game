extends Node3D
var chunks: Array[Chunk] = []
var temp_chunks = {}
var half_render_dis = int(Global.render_distance / 2)
var chunks_positions_to_load: Array[Vector3] = []
var task_id: int = 0

func create_chunk(chunk_index):
	var chunk_position = chunks_positions_to_load[chunk_index]
	var new_chunk = Chunk.new(chunk_position)
	new_chunk.create_mesh()
	temp_chunks[chunk_position] = new_chunk
	return
	
func load_chunks():
	for chunk in temp_chunks:
		if (chunk not in temp_chunks): continue
		if (not temp_chunks[chunk].hasMesh): continue
		var player_chunk_position = floor(Global.player_position / Global.chunks_size)
		var chunk_position = chunk / Global.chunks_size
		var dif = abs(player_chunk_position - chunk_position)
		if (dif.x > half_render_dis || dif.y > half_render_dis || dif.z > half_render_dis):
			temp_chunks[chunk].hide_mesh()
		else:
			if (temp_chunks[chunk].hasMesh):
				temp_chunks[chunk].show_mesh()
	
	if (task_id != 0):
		if (not WorkerThreadPool.is_group_task_completed(task_id)): return
	chunks_positions_to_load.clear()
	var player_chunk = floor(Global.player_position / Global.chunks_size)
	for i in range(1, Global.render_distance):
		for x in range(-i, i + 1):
			for z in range(-i, i + 1):
				# Teto & chão
				processChunks(Vector3(player_chunk.x + x, player_chunk.y - i, player_chunk.z + z))
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + i, player_chunk.z + z))
				if (z == -i or z == i): continue
				# pareide frente & trás
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + z, player_chunk.z - i))
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + z, player_chunk.z + i))
				if (x == -i or x == i): continue
				# pareides laterais
				processChunks(Vector3(player_chunk.x - i, player_chunk.y + z, player_chunk.z + x))
				processChunks(Vector3(player_chunk.x + i, player_chunk.y + z, player_chunk.z + x))
				
	task_id = WorkerThreadPool.add_group_task(create_chunk, chunks_positions_to_load.size(), 4, true)
				
func processChunks(chunk_position: Vector3):
	var global_chunk_position = chunk_position * Global.chunks_size
	if (global_chunk_position in temp_chunks): return
	chunks_positions_to_load.append(global_chunk_position)

func _ready() -> void:
	Global.world_node = self
	
func index_to_chunk_position(index: int):
	var max_i = Global.render_distance
	var x = index / (max_i * max_i)
	var y = (index / max_i) % max_i
	var z = index % max_i
	return Vector3(x,y,z)
