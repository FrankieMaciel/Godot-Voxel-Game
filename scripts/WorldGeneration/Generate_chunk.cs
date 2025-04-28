using Godot;
using System;
using System.Linq;

public partial class Generate_chunk : Node
{
    public Generate_chunk(Chunk chunk) {
        Generate(chunk, new Chunk_ground());
	    Generate(chunk, new Chunk_grass());
    }
    private void Generate(Chunk chunk, Chunk_base gen_class) {
        for (int block_index = 0; block_index < Math.Pow(Config.Chunk_size_with_border, 3) ; block_index++) {
            Vector3 block_position = chunk.index_to_coordinates3D(block_index);
            short block_id = gen_class.generate(chunk, block_position);
            if (block_id != 0 && chunk.isCompletlyEmpty) {
                chunk.data = [.. Enumerable.Repeat((short)0, (int)Math.Pow(Config.Chunk_size_with_border, 3))];
                chunk.isCompletlyEmpty = false; 
                continue;
            }
            if (block_id != 0 && !chunk.is_on_chunk_border(block_position)) {
                chunk.isEmpty = false;
            }
		    if (block_id == 0) { 
                chunk.isFull = false;
            }
            if (!chunk.isCompletlyEmpty) {
                chunk.data[block_index] = block_id;
            }
        }
    }
}
