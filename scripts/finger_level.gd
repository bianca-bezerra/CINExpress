extends GameLevel
class_name FingerLevel

var is_win := false

func _process(_delta: float) -> void:
	if is_win:
		get_tree().change_scene_to_file("res://scenes/levels/type_quickly.tscn")
