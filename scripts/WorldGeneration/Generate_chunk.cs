using Godot;
using System;

public partial class Generate_chunk : Node
{
    public Generate_chunk(Chunk chunk) {
        Generate(chunk, new Chunk_ground());
	    Generate(chunk, new Chunk_grass());
    }
    private void Generate(Chunk chunk, Chunk_base gen_class) {
        for (int block_index = 0; block_index < chunk.data.Count ; block_index++) {
            Vector3 block_position = chunk.index_to_coordinates3D(block_index);
            short block_id = gen_class.generate(chunk, block_position);
            chunk.data[block_index] = block_id;
            if (block_id != 0 && !chunk.is_on_chunk_border(block_position)) {
                chunk.isEmpty = false;
            }
		    if (block_id == 0) { 
                chunk.isFull = false;
            }
        }
    }
}
