extends Node2D
@onready var sprite: AnimatedSprite2D = $AtendantSprite
@onready var blink_timer: Timer = $Blink

var in_idle = true

func _ready() -> void:
	blink_timer.start()

func _on_blink_timeout() -> void:
	var time = randi_range(3, 5)
	if in_idle:
		sprite.play("blink")
		blink_timer.start(time)
