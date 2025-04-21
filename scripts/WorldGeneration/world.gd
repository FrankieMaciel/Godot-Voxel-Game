extends Node3D
var chunks: Array[Chunk] = []
var temp_chunks = {}
var half_render_dis = int(Global.render_distance / 2)
var chunks_positions_to_load: Array[Vector3] = []
var task_id: int = 0
var last_player_pos = Vector3.ZERO
var ni = 0

func create_chunk(chunk_index):
	var chunk_position = chunks_positions_to_load[chunk_index]
	var new_chunk = Chunk.new(chunk_position)
	new_chunk.create_mesh()
	temp_chunks[chunk_position] = new_chunk
	return
	
func load_chunks():
	var player_chunk = floor(Global.player.global_position / Global.chunks_size)
	if (player_chunk == last_player_pos): return
	for chunk in temp_chunks:
		if (chunk not in temp_chunks): continue
		if (not temp_chunks[chunk].hasMesh): continue
		var chunk_position = chunk / Global.chunks_size
		var dif = abs(player_chunk - chunk_position)
		if (dif.x > half_render_dis || dif.y > half_render_dis || dif.z > half_render_dis):
			temp_chunks[chunk].hide_mesh()
		else:
			if (temp_chunks[chunk].hasMesh):
				temp_chunks[chunk].show_mesh()
	
	while(ni < half_render_dis):
		if (player_chunk != last_player_pos): 
			ni = 0
		last_player_pos = player_chunk
		if (task_id != 0):
			if (not WorkerThreadPool.is_group_task_completed(task_id)): return
		chunks_positions_to_load.clear()
		for x in range(-ni, ni + 1):
			for z in range(-ni, ni + 1):
				# Teto & chão
				processChunks(Vector3(player_chunk.x + x, player_chunk.y - ni, player_chunk.z + z))
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + ni, player_chunk.z + z))
				if (z == -ni or z == ni): continue
				# pareide frente & trás
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + z, player_chunk.z - ni))
				processChunks(Vector3(player_chunk.x + x, player_chunk.y + z, player_chunk.z + ni))
				if (x == -ni or x == ni): continue
				# pareides laterais
				processChunks(Vector3(player_chunk.x - ni, player_chunk.y + z, player_chunk.z + x))
				processChunks(Vector3(player_chunk.x + ni, player_chunk.y + z, player_chunk.z + x))	
		task_id = WorkerThreadPool.add_group_task(create_chunk, chunks_positions_to_load.size(), -1)
		ni += 1
	ni = 0
				
func processChunks(chunk_position: Vector3):
	var global_chunk_position = chunk_position * Global.chunks_size
	if (global_chunk_position in temp_chunks): return
	chunks_positions_to_load.append(global_chunk_position)

func _ready() -> void:
	Global.world_node = self
	
func _process(delta: float) -> void:
	load_chunks()
	
func index_to_chunk_position(index: int):
	var max_i = Global.render_distance
	var x = index / (max_i * max_i)
	var y = (index / max_i) % max_i
	var z = index % max_i
	return Vector3(x,y,z)


func _on_h_slider_value_changed(value: float) -> void:
	Global.render_distance = value
	half_render_dis = int(Global.render_distance / 2)
	pass # Replace with function body.
