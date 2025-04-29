using Godot;
using Godot.Collections;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Block : Node
{
    public static ShaderMaterial chunk_shader = new();
    public enum Blocks {
        Air, 
        Stone,
        Dirt,
        Grass,
        Glass,
        Flowers,
        TallGrass,
    };
    public static Material chunk_material = new();
    private Array<Image> images_array = [];

    public static System.Collections.Generic.Dictionary<short, Block_Base> id_to_block = new()
    {
        {0, new Air()},
        {1, new Stone()},
        {2, new Dirt()},
        {3, new Grass()},
        {4, new Glass()},
        {5, new Flowers()},
        {6, new TallGrass()},
    };

    public override void _Ready() {
        chunk_material = (Material)ResourceLoader.Load("res://Materials/chunk_material.tres");
        GD.Print(chunk_material);
    }
}
