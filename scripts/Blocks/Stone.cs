using Godot;
using System;

public partial class Stone : Block_Base
{
    public override short GetTexture(Vector3 normal)
    {
        return 1;
    }
}
