extends VBoxContainer

@onready var mao = $Mao
var current_button: Button

func _ready():
	for child in get_children():
		if child is Button:
			child.connect("focus_entered", Callable(self, "_on_button_focus_entered"))
	
	current_button = get_node("StartButton")
	#mao.visible = true
	mao.global_position.y = current_button.global_position.y

func _on_button_focus_entered(button: Button):
	print("pronto")
	current_button = button
	move_mao_to_button(button)

func move_mao_to_button(button: Button):
	var target_y = button.global_position.y
	mao.create_tween().tween_property(mao, "global_position:y", target_y, 0.2)
