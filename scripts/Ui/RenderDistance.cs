using Godot;
using System;

public partial class RenderDistance : Label
{
    public override void _Process(double delta)
    {
        Text = Config.render_distance.ToString();
    }
}
