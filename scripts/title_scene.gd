extends Node2D

@onready var start_button = $GUI/GUIControl/ButtonGroup/StartButton
@onready var rank_button = $GUI/GUIControl/ButtonGroup/RankButton
@onready var about_button = $GUI/GUIControl/ButtonGroup/AboutButton
@onready var exit_button = $GUI/GUIControl/ButtonGroup/ExitButton

func _ready() -> void:
	start_button.grab_focus.call_deferred()
	start_button.connect("pressed", _on_start_button_pressed)
	rank_button.connect("pressed", _on_rank_button_pressed)
	about_button.connect("pressed", _on_about_button_pressed)
	exit_button.connect("pressed", _on_exit_button_pressed)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_rank_button_pressed() -> void:
	GameManager.change_to_ranking()
	
func _on_about_button_pressed() -> void:
	print("Não implementado ainda")
	
func _on_start_button_pressed() -> void:
	GameManager.change_to_username_scene()
