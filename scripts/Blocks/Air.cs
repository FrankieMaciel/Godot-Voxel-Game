using Godot;
using System;

public partial class Air : Block_Base
{
    public override bool isTransparent => true;
    public override short GetTexture(Vector3 normal)
    {
        return 0;
    }
}
