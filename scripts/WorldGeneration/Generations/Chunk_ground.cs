using Godot;
using System;

public partial class Chunk_ground : Chunk_base
{
    FastNoiseLite noise = new FastNoiseLite();

    public Chunk_ground() {
        noise.NoiseType = FastNoiseLite.NoiseTypeEnum.SimplexSmooth;
	    noise.Frequency = 0.005f;
    }
    public override short generate(Chunk chunk, Vector3 block_position) {
        Vector3 block_global_position = block_position + chunk.chunk_position;
        short block_id = (short)Block.Blocks.Air;
        float value = noise.GetNoise2D(block_global_position.X, block_global_position.Z);
        float value2 = noise.GetNoise2D(block_global_position.X / 10, block_global_position.Z / 10);
        if (block_global_position.Y < MathF.Round((float)Math.Sin(value + 1) * 64 * (value2 + 1))) {
            block_id = (short)Block.Blocks.Stone;
        } 
        var cave_value = noise.GetNoise3D(block_global_position.X * 2, block_global_position.Y * 2, block_global_position.Z * 2);
        if (cave_value > 0.5) {
            block_id = (short)Block.Blocks.Air;
        }
        return block_id;
    }
}
