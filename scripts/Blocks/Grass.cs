using Godot;
using System;

public partial class Grass : Block_Base
{
    public override short GetTexture(Vector3 normal)
    {
        if (normal == new Vector3(0,1,0)) return 3;
        if (normal == new Vector3(0,-1,0)) return 2;
        else return 4;
    }
}
