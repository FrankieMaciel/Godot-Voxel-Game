extends Node
class_name  ChunkGrassGeneration

var noise = FastNoiseLite.new()

func _init() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.01

func generate(chunk: Chunk, block_position: Vector3):
	var block_id = chunk.get_block_at(block_position)
	if (chunk.is_on_chunk_border(block_position)): return block_id
	var block_on_top = Vector3(block_position.x,block_position.y + 1,block_position.z)
	if (chunk.get_block_at(block_position) == Block.getBlockId("Stone") and chunk.get_block_at(block_on_top) == 0):
		block_id = Block.getBlockId("Grass")
		chunk.set_block_at(block_position - Vector3(0,1,0), Block.getBlockId("Dirt"))
	return block_id
