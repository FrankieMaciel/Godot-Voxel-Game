extends Label

func _process(delta: float) -> void:
	text = "Render distance: " + str(Global.render_distance)
