extends Node

const blocks = [
	"Air",
	"Stone"
]

var ids = {}

func _ready() -> void:
	for index in range(0, len(blocks)):
		ids[blocks[index]] = index 
		
func getBlockId(block_name: String):
	return ids[block_name]
