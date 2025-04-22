extends Node

const blocks = [
	"Air",
	"Stone",
	"Dirt",
	"Grass",
	"Grass_Side"
]
const textures = [
	"res://textures/Dirt.png",
	"res://textures/Stone.png",
	"res://textures/Dirt.png",
	"res://textures/Grass.png",
	"res://textures/Grass_Side.png"
]
var texture_array: Texture2DArray = Texture2DArray.new()
var images_array: Array[Image] = []

var ids_to_texture = {}

var ids = {}

func _ready() -> void:
	
	texture_array = ResourceLoader.load("res://texture_2d_array.res")
	var hasToCreate = false
	if (texture_array.get_layers() == 0): hasToCreate = true
	
	for index in range(0, len(blocks)):
		ids[blocks[index]] = index 
		ids_to_texture[index] = textures[index]
		if (hasToCreate):
			var img = Image.new()
			img.load(textures[index])
			images_array.append(img)
	
	print(texture_array.get_layers())
	if (hasToCreate):
		texture_array.create_from_images(images_array)
		ResourceSaver.save(texture_array, "res://texture_2d_array.res", ResourceSaver.FLAG_COMPRESS)
		
func getBlockId(block_name: String):
	return ids[block_name]
