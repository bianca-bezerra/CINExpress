extends Node2D

const Portrait = preload("res://scripts/delivery/cin_portrait.gd")

@export var lift: float = 16.0
@export var transition_duration: float = 0.1
@export var inactive_tint := Color(0.58, 0.58, 0.65)
@export var portrait_region := Rect2()

@onready var _name_font_size: int = $Name.get_theme_font_size("font_size")

var data: Dictionary
var _rest_position := Vector2.ZERO
var _motion: Tween


func setup(card_data: Dictionary, texture: Texture2D, rest_position: Vector2) -> void:
	data = card_data
	_rest_position = rest_position
	position = rest_position
	$Photo/Portrait.texture = Portrait.from_character(texture, portrait_region)
	$Name.text = card_data["name"]
	_fit_name()
	set_selected(false, true)


func _fit_name() -> void:
	var label: Label = $Name
	var font_size := _name_font_size
	label.add_theme_font_size_override("font_size", font_size)
	while font_size > 6 and label.get_line_count() > label.get_visible_line_count():
		font_size -= 1
		label.add_theme_font_size_override("font_size", font_size)


func set_selected(selected: bool, immediate: bool = false) -> void:
	if _motion:
		_motion.kill()
	var destination := _rest_position - Vector2(0, lift if selected else 0.0)
	var tint := Color.WHITE if selected else inactive_tint
	z_index = 8 if selected else 0
	$Highlight.visible = selected
	if immediate:
		position = destination
		modulate = tint
		return
	_motion = create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_motion.tween_property(self, "position", destination, transition_duration)
	_motion.tween_property(self, "modulate", tint, transition_duration)
