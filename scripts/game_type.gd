extends LineEdit
class_name GameType

@export var retain_input_focus := true

func _on_text_changed(_new_text: String) -> void:
	AudioManager.play_sfx("text_type")
	
func _on_text_submitted(_new_text: String) -> void:
	AudioManager.play_sfx("button_click")

## Workaround para sempre ter o foco
func _unhandled_input(_event: InputEvent) -> void:
	if retain_input_focus:
		grab_focus()
