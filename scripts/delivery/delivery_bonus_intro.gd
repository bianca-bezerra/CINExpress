extends Node2D

const STAR_SHEET: Texture2D = preload("res://assets/sprites/Star.png")

@export var message_duration: float = 4.5

var _can_continue := false
var _leaving := false
var _motion_time := 0.0
var _star_positions: Array[Vector2] = []
@onready var _stars: Array[AnimatedSprite2D] = [
	$Decor/StarLeftTop,
	$Decor/StarRightTop,
	$Decor/StarLeftBottom,
	$Decor/StarRightBottom,
]


func _ready() -> void:
	GameManager.set_ui_visible(false)
	$Speech/Message.text = "[center]Agora é [color=#a44c0c][font_size=12]hora da entrega![/font_size][/color]\nEntregue o máximo de CINs\nem %d segundos![/center]" % int(GameManager.delivery_bonus_duration)
	# Nesta apresentação a assistente é quem dá o aviso; não altera a preferência global.
	$Assistant.set_process(false)
	$Assistant.visible = true
	$Assistant.modulate.a = 0.0
	$Hint.visible = false
	$Speech.modulate.a = 0.0
	$Decor.modulate.a = 0.0
	_setup_stars()
	# Executar esta cena sozinha no editor deixa o aviso disponível para edição.
	if not GameManager.delivery_bonus_active:
		_show_celebration()
		$Hint.visible = true
		return
	var transition: AnimationPlayer = GameManager.scene_transintion_animation
	if transition.is_playing() and transition.current_animation == "fade_out":
		await transition.animation_finished
	if not is_inside_tree():
		return
	_show_celebration()
	_can_continue = true
	$Hint.visible = true
	await get_tree().create_timer(message_duration).timeout
	if is_inside_tree():
		_start_delivery()


func _setup_stars() -> void:
	var frames := SpriteFrames.new()
	frames.set_animation_speed("default", 8.0)
	frames.set_animation_loop("default", true)
	for i in 13:
		var frame := AtlasTexture.new()
		frame.atlas = STAR_SHEET
		frame.region = Rect2(i * 32, 0, 32, 32)
		frame.filter_clip = true
		frames.add_frame("default", frame)
	for i in _stars.size():
		var star := _stars[i]
		_star_positions.append(star.position)
		star.sprite_frames = frames
		star.play("default")
		star.frame = (i * 3) % 13


func _show_celebration() -> void:
	var speech: Control = $Speech
	var assistant: Node2D = $Assistant
	var speech_destination := speech.position
	var assistant_destination := assistant.position
	speech.position += Vector2(0, 8)
	speech.scale = Vector2(0.94, 0.94)
	assistant.position += Vector2(-24, 10)
	var entrance := create_tween().set_parallel()
	entrance.tween_property(assistant, "position", assistant_destination, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrance.tween_property(assistant, "modulate:a", 1.0, 0.25)
	entrance.tween_property(speech, "position", speech_destination, 0.45).set_delay(0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrance.tween_property(speech, "scale", Vector2.ONE, 0.45).set_delay(0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entrance.tween_property(speech, "modulate:a", 1.0, 0.2).set_delay(0.18)
	entrance.tween_property($Decor, "modulate:a", 1.0, 0.45)
	var hint_pulse := create_tween().set_loops()
	hint_pulse.tween_property($Hint, "modulate:a", 0.55, 0.55)
	hint_pulse.tween_property($Hint, "modulate:a", 1.0, 0.55)


func _process(delta: float) -> void:
	_motion_time += delta
	$Decor/CinLeft.position.y = 132.0 + sin(_motion_time * 2.5) * 5.0
	$Decor/CinRight.position.y = 148.0 + sin(_motion_time * 2.5 + 1.8) * 5.0
	$Decor/CinLeft.rotation = -0.16 + sin(_motion_time * 2.0) * 0.06
	$Decor/CinRight.rotation = 0.16 + sin(_motion_time * 2.0 + 1.8) * 0.06
	for i in _star_positions.size():
		_stars[i].position.y = _star_positions[i].y + sin(_motion_time * 2.4 + i) * 3.0


func _unhandled_input(event: InputEvent) -> void:
	if not _can_continue or _leaving:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select") or event.is_action_pressed("space"):
		get_viewport().set_input_as_handled()
		_start_delivery()


func _start_delivery() -> void:
	if _leaving or not GameManager.delivery_bonus_active:
		return
	_leaving = true
	_can_continue = false
	var transition: AnimationPlayer = GameManager.scene_transintion_animation
	transition.play("fade_in")
	await transition.animation_finished
	if is_inside_tree() and GameManager.delivery_bonus_active:
		GameManager.begin_delivery_bonus()
