extends Node
class_name  ChunkBaseGeneration

var noise = FastNoiseLite.new()

func _init() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.01

func generate(_data: Array[int], chunk_position: Vector3, block_position: Vector3):
	var block_global_position = block_position + chunk_position
	var block_id = Block.getBlockId("Air")
	var value = noise.get_noise_2d(block_global_position.x, block_global_position.z)
	if (block_global_position.y < (value * 16) + 8): block_id = Block.getBlockId("Stone")
	return block_id
