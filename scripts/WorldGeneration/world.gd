extends Node3D
var temp_chunks = {}
var half_render_dis = int(Global.render_distance / 2)
var chunks_positions_to_load: Array[Vector3] = []
var task_id: int = -1
var last_player_pos = Vector3.ZERO
var mesh_to_free = []

func create_chunk(chunk_index):
	var chunk_position = chunks_positions_to_load[chunk_index]
	var new_chunk = Chunk.new(chunk_position * Global.chunks_size)
	new_chunk.create_mesh()
	temp_chunks[chunk_position] = new_chunk
	return
	
func load_chunks():
	var player_chunk = floor(Global.player.global_position / Global.chunks_size)
	if (player_chunk == last_player_pos): return
	for chunk in temp_chunks:
		if (temp_chunks[chunk] == null): continue
		if (chunk not in temp_chunks): continue
		if (not temp_chunks[chunk].hasMesh): continue
		var chunk_position = chunk
		var dif = abs(player_chunk - chunk_position)
		if (dif.x > half_render_dis || dif.y > half_render_dis || dif.z > half_render_dis):
			temp_chunks[chunk].hide_mesh()
		else:
			if (temp_chunks[chunk].hasMesh):
				temp_chunks[chunk].show_mesh()
	
	if (task_id != -1):
		if (not WorkerThreadPool.is_group_task_completed(task_id)): return
	for mesh in mesh_to_free:
		mesh.call_deferred_thread_group("queue_free")
	mesh_to_free.clear()
	chunks_positions_to_load.clear()
	for i in range(0, half_render_dis):
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
	if (chunks_positions_to_load.size() > 0):
		task_id = WorkerThreadPool.add_group_task(create_chunk, chunks_positions_to_load.size(), -1)
				
func processChunks(chunk_position: Vector3):
	if (chunk_position in temp_chunks): return
	temp_chunks[chunk_position] = null
	chunks_positions_to_load.append(chunk_position)

func _ready() -> void:
	Global.world_node = self
	
func _process(_delta: float) -> void:
	load_chunks()

func _on_h_slider_value_changed(value: float) -> void:
	Global.render_distance = value
	half_render_dis = int(Global.render_distance / 2)
	pass # Replace with function body.
	
func updateChunkBlockInfo(pos: Vector3, normal: Vector3, block_id):
	var iblock_pos = null
	if (block_id == 0): iblock_pos = pos - (normal / 2)
	else: iblock_pos = pos + (normal / 2)
	var chunkPos = floor(iblock_pos / Global.chunks_size)
	if (chunkPos not in temp_chunks): return
	if (temp_chunks[chunkPos] == null): return
	var blockPos = (floor(iblock_pos) - (chunkPos * Global.chunks_size)) + Vector3(1,1,1)
	
	updateBlockInfo(chunkPos, iblock_pos, block_id)
	
	var adj_chunk = get_border_diference(blockPos, Global.chunks_size)
	if (adj_chunk != Vector3.ZERO):
		if (adj_chunk[0] != 0): 
			var adjChunkPos = chunkPos + (Vector3(adj_chunk[0],0,0))
			updateBlockInfo(adjChunkPos, iblock_pos, block_id)
		if (adj_chunk[1] != 0): 
			var adjChunkPos = chunkPos + (Vector3(0,adj_chunk[1],0))
			updateBlockInfo(adjChunkPos, iblock_pos, block_id)
		if (adj_chunk[2] != 0): 
			var adjChunkPos = chunkPos + (Vector3(0,0,adj_chunk[2]))
			updateBlockInfo(adjChunkPos, iblock_pos, block_id)
			
func updateBlockInfo(chunk_position: Vector3, block_position: Vector3, block_id: int):
	var chunk = temp_chunks[chunk_position]
	var blockPos = (floor(block_position) - (chunk_position * Global.chunks_size)) + Vector3(1,1,1)
	chunk.set_block_at(blockPos, block_id)
	chunk.create_mesh()
	pass
	
func get_border_diference(pos: Vector3, size):
	var nx = 0
	var ny = 0
	var nz = 0
	if (pos.x == size): nx = 1
	if (pos.x == 1): nx = -1
	if (pos.y == size): ny = 1
	if (pos.y == 1): ny = -1
	if (pos.z == size): nz = 1
	if (pos.z == 1): nz = -1
	return Vector3(nx,ny,nz)
