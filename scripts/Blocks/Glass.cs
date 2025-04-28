using Godot;
using System;

public partial class Glass : Block_Base
{
    public override bool isTransparent => true;
    public override short GetTexture(Vector3 normal)
    {
        return 5;
    }
}
