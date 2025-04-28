using Godot;
using System;
using System.Diagnostics;
using System.Text.RegularExpressions;

public partial class Player : CharacterBody3D
{
    float defaultSpeed = 5f;
    float DebugSpeed = 15f;
    float SPEED = 15f;
    float Debug_JUMP_VELOCITY = 14.5f;
    float JUMP_VELOCITY = 13.0f;
    float mouse_sens = 0.3f;
    float camera_anglev = 0f;
    Vector3 lastChunkPos;
    bool freeze = false;
    Camera3D playerCam;
    RayCast3D playerRay;
    public Vector3 playerBlock;
    public Vector3 player_chunk;
    bool debugMode = false;
    public bool isEsgueirado = false;

     public Player() {
     }
    public override void _Ready()
    {
        playerCam = GetNode<Camera3D>("Camera3D");
        playerRay = GetNode<RayCast3D>("Camera3D/RayCast3D");
        Input.SetMouseMode(Input.MouseModeEnum.Captured);
        Config.player = this;
        GetNode<Slider>("ColorRect/HSlider").Value = Config.render_distance;
         if (debugMode) {
            GetNode<CollisionShape3D>("CollisionShape3D").Disabled = false;
            GetNode<CollisionShape3D>("CollisionShape3D2").Disabled = false;
         } else {
            GetNode<CollisionShape3D>("CollisionShape3D").Disabled = true;
            GetNode<CollisionShape3D>("CollisionShape3D2").Disabled = false;
         }
    }

    public override void _Input(InputEvent @event)
    {
        if (Config.is_paused) return;
        if (@event is InputEventMouseMotion) {
            InputEventMouseMotion m = (InputEventMouseMotion) @event;
            RotateY(Mathf.DegToRad(-m.Relative.X * mouse_sens));
            float changev = -m.Relative.Y * mouse_sens;
            var new_camera_anglev = camera_anglev + changev;
            if (new_camera_anglev > -90 && new_camera_anglev < 90) {
                camera_anglev = new_camera_anglev;
                playerCam.RotateX(Mathf.DegToRad(changev));
            }
        }
        if (@event is InputEventMouseButton) {
            InputEventMouseButton m = (InputEventMouseButton) @event;
            if (@event.IsPressed()) {
                switch (m.ButtonIndex) {
                    case MouseButton.Left:
                        if (playerRay.IsColliding()) {
                            Config.world_node.updateChunkBlockInfo(playerRay.GetCollisionPoint(), playerRay.GetCollisionNormal(), 0);
                        }
                    break;
                    case MouseButton.Right:
                        if (playerRay.IsColliding()) {
                            Config.world_node.updateChunkBlockInfo(playerRay.GetCollisionPoint(), playerRay.GetCollisionNormal(), 4);
                        }
                    break;
                    case MouseButton.WheelUp:
                        GD.Print("Scroll wheel up");
                    break;
                    case MouseButton.WheelDown:
                        GD.Print("Scroll wheel down");
                    break;
                }
            }
        }
    }
    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("ui_menu")) {
            if (!Config.is_paused) {
                Input.SetMouseMode(Input.MouseModeEnum.Visible);
                Config.is_paused = true;
                GetNode<ColorRect>("ColorRect").Visible = true;
            } else {
                Input.SetMouseMode(Input.MouseModeEnum.Captured);
                Config.is_paused = false;
                GetNode<ColorRect>("ColorRect").Visible = false;
            }
        }
    }
    public override void _PhysicsProcess(double delta)
    {
        if (Config.is_paused) return;
        if (Config.world_node.block_on_top_of_player == 0 && isEsgueirado && !Input.IsKeyPressed(Key.Shift)) {
            CollisionShape3D playerColl = GetNode<CollisionShape3D>("CollisionShape3D2");
            playerColl.Disabled = false;
            CollisionShape3D playerColl2 = GetNode<CollisionShape3D>("CollisionShape3D");
            playerColl2.Disabled = true;
            Tween tweenCamera = GetTree().CreateTween();
            tweenCamera.TweenProperty(GetNode<Camera3D>("Camera3D"), "position:y", 0.6f, 0.1f);
            isEsgueirado = false;
        }
        player_chunk = GlobalPosition / Config.Chunk_size;
        player_chunk = player_chunk.Floor() * Config.Chunk_size;
        playerBlock = GlobalPosition - player_chunk;
        playerBlock = playerBlock.Floor() + new Vector3(1,1,1);
        GetNode<Label>("Label").Text = Convert.ToString(Engine.GetFramesPerSecond()) + " " + Convert.ToString(GlobalPosition) + " Esc para pausar";
        Vector3 n_velocity = Velocity;
        if (!debugMode) {
            SPEED = defaultSpeed;
            if (isEsgueirado) SPEED = defaultSpeed / 2;
            if (!IsOnFloor()) n_velocity.Y -= (float)(52 * delta);
            if (Input.IsActionPressed("ui_accept") && IsOnFloor() && !isEsgueirado) {
                n_velocity.Y += JUMP_VELOCITY;
            }
            if (Input.IsKeyPressed(Key.Shift)) {
                CollisionShape3D playerColl = GetNode<CollisionShape3D>("CollisionShape3D2");
                playerColl.Disabled = false;
                CollisionShape3D playerColl2 = GetNode<CollisionShape3D>("CollisionShape3D");
                playerColl2.Disabled = true;
                Tween tweenCamera = GetTree().CreateTween();
                tweenCamera.TweenProperty(GetNode<Camera3D>("Camera3D"), "position:y", 0f, 0.1f);
                isEsgueirado = true;
            }
        } else {
            SPEED = DebugSpeed;
            n_velocity.Y = 0;
            if (Input.IsActionPressed("ui_accept")) {
                n_velocity.Y = Debug_JUMP_VELOCITY;
            }
            if (Input.IsKeyPressed(Key.Shift)) {
                n_velocity.Y = -Debug_JUMP_VELOCITY;
            }
            if (Input.IsKeyPressed(Key.Shift) && Input.IsActionPressed("ui_accept")) {
                n_velocity.Y = 0;
            }
        }
    
        if (Input.IsKeyPressed(Key.Ctrl) && !isEsgueirado) {
            SPEED = defaultSpeed * 1.5f;
        }
        var input_dir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
        var direction = (Transform.Basis * new Vector3(input_dir.X, 0, input_dir.Y)).Normalized();
        if (direction != Vector3.Zero) {
            n_velocity.X = direction.X * SPEED;
            n_velocity.Z = direction.Z * SPEED;
        } else {
            n_velocity.X = Mathf.MoveToward(n_velocity.X, 0, 1);
            n_velocity.Z = Mathf.MoveToward(n_velocity.Z, 0, 1);
        }
        Velocity = n_velocity;
        MoveAndSlide();
    }
}
