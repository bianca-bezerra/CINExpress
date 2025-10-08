extends Node2D

@onready var start_button = $GUI/GUIControl/ButtonGroup/StartButton
@onready var exit_button = $GUI/GUIControl/ButtonGroup/ExitButton

func _ready() -> void:
	start_button.grab_focus.call_deferred()
	start_button.connect("pressed", _on_start_button_pressed)
	exit_button.connect("pressed", _on_exit_button_pressed)
	
func _process(_delta: float) -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	GameManager.start_game()
	get_tree().change_scene_to_file("res://scenes/levels/finger_scene.tscn")
