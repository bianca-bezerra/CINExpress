extends Node2D

@onready var start_button = $GUI/GUIControl/ButtonGroup/StartButton
@onready var rank_button = $GUI/GUIControl/ButtonGroup/RankButton
@onready var credit_button = $GUI/GUIControl/ButtonGroup/CreditButton
@onready var exit_button = $GUI/GUIControl/ButtonGroup/ExitButton

func _ready() -> void:
	start_button.grab_focus.call_deferred()
	start_button.connect("pressed", _on_start_button_pressed)
	rank_button.connect("pressed", _on_rank_button_pressed)
	credit_button.connect("pressed", _on_credit_button_pressed)
	exit_button.connect("pressed", _on_exit_button_pressed)

func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
func _on_rank_button_pressed() -> void:
	GameManager.change_to_ranking()
	
func _on_credit_button_pressed() -> void:
	GameManager.change_to_credits()
	
func _on_start_button_pressed() -> void:
	GameManager.change_to_username_scene()
