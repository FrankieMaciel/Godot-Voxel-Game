using Godot;
using System;

public partial class Config : Node
{
    public static int Chunk_size { get; set; } = 16;
    public static int Chunk_size_with_border { get; set; } = Chunk_size + 2;
    public static int World_max_y { get; set; } = 256;
    public static int World_min_y { get; set; } = -64;
    public static World world_node { get; set; }
    public static int render_distance { get; set; } = 16;
    public static Player player { get; set; }
    public static bool is_paused { get; set; }

    public static System.Collections.Generic.Dictionary<DirectionsIndexes, Vector3> directions = new()
    {
        {DirectionsIndexes.up, new Vector3(0,1,0)},
        {DirectionsIndexes.down, new Vector3(0,-1,0)},
        {DirectionsIndexes.left, new Vector3(1,0,0)},
        {DirectionsIndexes.right, new Vector3(-1,0,0)},
        {DirectionsIndexes.front, new Vector3(0,0,1)},
        {DirectionsIndexes.back, new Vector3(0,0,-1)},
    };

    public enum DirectionsIndexes : byte {
        up,
        down,
        left,
        right,
        front,
        back,
    }
}
