extends GameLevel
class_name FingerLevel

var win_count = 0

func _process(_delta: float) -> void:
	if win_count >= 3:
		get_tree().change_scene_to_file("res://scenes/levels/type_quickly.tscn")
