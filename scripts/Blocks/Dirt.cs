using Godot;
using System;

public partial class Dirt : Block_Base
{
    public override short GetTexture(Vector3 normal)
    {
        return 2;
    }
}
