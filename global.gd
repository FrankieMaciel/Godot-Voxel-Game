extends Node

var world_node: Node3D = null
const world_max_y: int = 256
const world_min_y: int = -64
const chunks_size: int = 16
const chunks_size_with_border: int = chunks_size + 2

var player: Player
var player_position: Vector3
var render_distance = 8

const directions = {
	"up": Vector3(0,1,0),
	"down": Vector3(0,-1,0),
	"left": Vector3(1,0,0),
	"right": Vector3(-1,0,0),
	"front": Vector3(0,0,1),
	"back": Vector3(0,0,-1),
}

var directions_indeces = {}
var indeces_to_directions = {}

func _ready() -> void:
	var i = 0
	for dir in directions:
		indeces_to_directions[i] = dir
		directions_indeces[dir] = i
		i += 1
	
