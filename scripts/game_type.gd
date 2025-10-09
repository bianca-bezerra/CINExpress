extends LineEdit
class_name GameType


func _on_text_changed(_new_text: String) -> void:
	AudioManager.play_sfx("text_type")
	
func _on_text_submitted(_new_text: String) -> void:
	AudioManager.play_sfx("button_click")
