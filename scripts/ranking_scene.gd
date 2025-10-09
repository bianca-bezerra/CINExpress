extends Node2D

@onready var dashboard_panel = $CanvasLayer/Dashboard
@export var leatherboard_speed = 100

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameManager.change_to_menu_scene()

func _ready() -> void:
	var players = GameManager.get_dashboard()
	if not players:
		var label = Label.new()
		label.text = "Ainda não temos vencedores!"
		dashboard_panel.add_child(label)
	else:	# sort descending
		players.sort_custom(func(a, b): return a["score"] > b["score"])
		var winners = players.slice(0, 3)
		for ind in range(len(winners)):
			var label = Label.new()
			var count = ind + 1
			label.text = "%d - %s (%.2f)" % [count, winners[ind]["name"], winners[ind]["score"]]
			dashboard_panel.add_child(label)

var _angle = 0
func _process(delta: float) -> void:
	var dash_children = dashboard_panel.get_children()
	for ind in range(len(dash_children)):
		_angle += delta * 2
		dash_children[ind].position.y = 10 * cos(_angle + (ind+1))
