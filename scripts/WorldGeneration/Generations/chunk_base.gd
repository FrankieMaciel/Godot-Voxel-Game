extends Node
class_name  ChunkBaseGeneration

var noise = FastNoiseLite.new()

func _init() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.005

func generate(chunk: Chunk, block_position: Vector3):
	var block_global_position = block_position + chunk.chunk_position
	var block_id = Block.getBlockId("Air")
	var value = noise.get_noise_2d(block_global_position.x, block_global_position.z)
	if (block_global_position.y < round(value * 64) + 8): block_id = Block.getBlockId("Stone")
	var cave_value = noise.get_noise_3d(block_global_position.x * 2, block_global_position.y * 2, block_global_position.z * 2)
	if (cave_value > 0.5): block_id = Block.getBlockId("Air")
	return block_id
