extends CanvasLayer
@export var shake_amount = 1
@export var velocity = 7

@onready var logo: TextureRect = $GUIControl/Logo
@onready var default_logo_pos = logo.position


var _angle = 0

func _process(delta: float) -> void:
	_angle += delta * velocity
	var _dest = default_logo_pos.x + 10 * cos(_angle)
	var _angle_dest = shake_amount * sign(cos(_angle))
	logo.position.x = lerp(logo.position.x, _dest, 0.1)
	logo.rotation_degrees = lerp(logo.rotation_degrees, _angle_dest, 0.1)
	
	
