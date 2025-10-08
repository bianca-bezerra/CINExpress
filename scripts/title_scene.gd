extends Node2D

@onready var start_button = $GUI/GUIControl/ButtonGroup/StartButton
@onready var exit_button = $GUI/GUIControl/ButtonGroup/ExitButton
@onready var dashboard_panel = $GUI/GUIControl/Dashboard
@export var leatherboard_speed = 100

func _ready() -> void:
	var players = GameManager.get_dashboard()
	if not players:
		var label = Label.new()
		label.text = "Ainda não temos vencedores!"
		dashboard_panel.add_child(label)
	else:		# sort descending
		players.sort_custom(func(a, b): return a["score"] > b["score"])
		var winners = players.slice(0, 3)
		for ind in range(len(winners)):
			var label = Label.new()
			var count = ind + 1
			label.text = "%d - %s (%.2f)" % [count, winners[ind]["name"], winners[ind]["score"]]
			dashboard_panel.add_child(label)

	start_button.grab_focus.call_deferred()
	start_button.connect("pressed", _on_start_button_pressed)
	exit_button.connect("pressed", _on_exit_button_pressed)

var _angle = 0
func _process(delta: float) -> void:
	var dash_children = dashboard_panel.get_children()
	for ind in range(len(dash_children)):
		_angle += delta * 2
		dash_children[ind].position.y = 10 * cos(_angle + (ind+1))
		
func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	GameManager.change_to_username_scene()
