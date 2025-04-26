using Godot;
using System;

public abstract partial class Block_Base : Node
{
    public abstract short GetTexture(Vector3 normal);
}
