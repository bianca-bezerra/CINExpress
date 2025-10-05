extends Label

@export var added_score: float = 0.0

func _ready() -> void:
	text = "+ %.2f " % added_score
	

func _process(delta: float) -> void:
	modulate.a -= delta
	global_position.y -= delta * 2
	if modulate.a < 0:
		queue_free()
