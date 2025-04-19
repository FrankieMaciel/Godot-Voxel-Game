extends Node
class_name ChunkGeneration

func _init(chunk: Chunk) -> void:
	generate(chunk, ChunkBaseGeneration.new().generate)

func generate(chunk: Chunk, generation_function: Callable) -> void:
	for block_index in range(0, len(chunk.data)):
		var block_position = chunk.index_to_coordinates3D(block_index)
		var block_id = generation_function.call(chunk.data, chunk.chunk_position, block_position)
		chunk.data[block_index] = block_id
		if (block_id == 1 and not chunk.is_on_chunk_border(block_position)):
			chunk.isEmpty = false
		else: chunk.isFull = false
