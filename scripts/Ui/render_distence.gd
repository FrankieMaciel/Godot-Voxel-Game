extends Label

func _process(_delta: float) -> void:
	text = "Render distance: " + str(Global.render_distance)
