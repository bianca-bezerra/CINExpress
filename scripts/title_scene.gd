extends Node2D

@onready var start_button = $GUI/ButtonGroup/StartButton
@onready var exit_button = $GUI/ButtonGroup/ExitButton


func _ready() -> void:
	start_button.grab_focus.call_deferred()
	
func _process(_delta: float) -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	GameManager.start_game()
	GameManager.change_to_next_level()
