extends CharacterBody3D
class_name Player

const defaultSpeed = 15.0
var SPEED = 15.0
const JUMP_VELOCITY = 14.5
var freeze = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var playerCam = $Camera3D
#@onready var playerRay = $Camera3D/RayCast3D

var mouse_sens = 0.3
var camera_anglev = 0

var lastChunkPos: Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.player = self
	pass

func _input(event):
	if (Global.is_paused): return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		
		var changev = -event.relative.y * mouse_sens
		var new_camera_anglev = camera_anglev + changev
		
		if new_camera_anglev > -90 and new_camera_anglev < 90:
			camera_anglev = new_camera_anglev
			$Camera3D.rotate_x(deg_to_rad(changev))
			
	#if event is InputEventMouseButton and event.pressed:
		#match event.button_index:
			#MOUSE_BUTTON_LEFT:
				#if (playerRay.is_colliding()):
					#$Camera3D/Arma/CPUParticles3D.emitting = true
					#$Camera3D/Arma/Timer.start()
					#Globals.World.updateChunkBlockInfo(playerRay.get_collision_point(), playerRay.get_collision_normal(), 0)
			#MOUSE_BUTTON_RIGHT:
				#if (playerRay.is_colliding()):
					#$Camera3D/Arma/CPUParticles3D.emitting = true
					#$Camera3D/Arma/Timer.start()
					#Globals.World.updateChunkBlockInfo(playerRay.get_collision_point(), playerRay.get_collision_normal(), 3)
					
				#print("Right mouse button")
			#MOUSE_BUTTON_WHEEL_UP:
				#print("Scroll wheel up")
			#MOUSE_BUTTON_WHEEL_DOWN:
				#print("Scroll wheel down")
				
func  _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_menu"):
		if (not Global.is_paused):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Global.is_paused = true
			$ColorRect.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Global.is_paused = false
			$ColorRect.visible = false
				

func _physics_process(_delta):
	if (Global.is_paused): return
	$Label.text = str(Engine.get_frames_per_second()) + " " + str(global_position) + " Esc para pausar"
	SPEED = defaultSpeed
	#velocity.y -= (gravity * 5) * delta
	velocity.y = 0
	if Input.is_action_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY

	if Input.is_key_pressed(KEY_SHIFT):
		velocity.y = -JUMP_VELOCITY

	if Input.is_key_pressed(KEY_SHIFT) && Input.is_action_pressed("ui_accept"):
		velocity.y = 0

	if Input.is_key_pressed(KEY_CTRL):
		SPEED = defaultSpeed * 2

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
