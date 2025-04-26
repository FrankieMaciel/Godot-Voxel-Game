using Godot;
using System;

public abstract partial class Chunk_base : Node
{
    public abstract short generate(Chunk chunk, Vector3 block_position);
}
