extends Button
class_name GameButton

func _on_pressed() -> void:
	AudioManager.play_sfx("button_click")

func _on_focus_entered(_arg = null) -> void:
	AudioManager.play_sfx("button_hover")

func _on_focus_exited() -> void:
	pass # Replace with function body.
	
	
