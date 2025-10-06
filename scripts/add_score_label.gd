extends Label	

func _process(delta: float) -> void:
	modulate.a -= delta
	global_position.y -= delta * 2
	if modulate.a < 0:
		queue_free()
