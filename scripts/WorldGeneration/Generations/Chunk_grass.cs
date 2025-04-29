using Godot;
using System;

public partial class Chunk_grass : Chunk_base
{
    Random rdn = new();
    public override short generate(Chunk chunk, Vector3 block_position) {
        short block_id = chunk.get_block_at(block_position);
        Vector3 globalBlockPos = chunk.chunk_position + block_position;
        if (globalBlockPos.Y < 16) return block_id;
        if (chunk.is_on_chunk_border(block_position)) {
            return block_id;
        }
        var block_on_top = new Vector3(block_position.X,block_position.Y + 1,block_position.Z);
        if (chunk.get_block_at(block_position) == (short)Block.Blocks.Stone && chunk.get_block_at(block_on_top) == (short)Block.Blocks.Air) {
            int rndn = rdn.Next(0,13);
            if (rndn == 0) chunk.set_block_at(block_on_top, (short)Block.Blocks.Flowers);
            if (rndn == 1) chunk.set_block_at(block_on_top, (short)Block.Blocks.TallGrass);
            block_id = (short)Block.Blocks.Grass;
            chunk.set_block_at(block_position - new Vector3(0,1,0), (short)Block.Blocks.Dirt);
        }
        return block_id;
    }
}
