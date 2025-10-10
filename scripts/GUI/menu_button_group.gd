extends VBoxContainer

@onready var mao: Node2D = $Mao	
@onready var default_hand_y = mao.global_position.x


var current_button: Button
var default_y = 0

func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.connect("focus_entered", Callable(self, "_on_button_focus_entered").bind(child))
			child.connect("pressed", Callable(self, "_on_button_pressed"))
	
	current_button = $StartButton
	default_y = current_button.global_position.y
	mao.global_position.y = current_button.global_position.y

var _ac = 0
func _process(_delta: float) -> void:
	_ac += _delta
	var _dest_x = current_button.global_position.x - len(current_button.text) * 2 + 3 * sin(_ac*10)
	mao.global_position.x = lerp(mao.global_position.x, _dest_x, 0.1)

func move_button_up(button: Button):
	var target_y = button.global_position.y - 2
	var tween = get_tree().create_tween()
	tween.tween_property(button, "global_position:y", target_y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func reset_button_pos(button: Button):
	var target_y = default_y
	var tween = get_tree().create_tween()
	tween.tween_property(button, "global_position:y", target_y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
func _on_button_focus_entered(button: Button) -> void:
	AudioManager.play_sfx("button_hover", randf_range(0.9, 1.1))
	reset_button_pos(current_button)
	current_button = button
	default_y = current_button.global_position.y
	move_mao_to_button(button)
	move_button_up(current_button)

func _on_button_pressed():
	AudioManager.play_sfx("button_click")

func move_mao_to_button(button: Button) -> void:
	var target_y = button.global_position.y+button.size.y/2
	var tween = get_tree().create_tween()
	tween.tween_property(mao, "global_position:y", target_y, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
