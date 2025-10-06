extends CharacterBody2D

@export var speed = 0
@onready var _scoring_zone: Area2D = $"../digital_reader"
@onready var _level = $".."

const FINGER_MARGIN = 80

const SPEED_INCREASE = 200.0
const MAX_SCORE_PER_HIT = 100
const SCREEN_LIMIT_LEFT = 0.0 + FINGER_MARGIN
const SCREEN_LIMIT_RIGHT = 480.0 - FINGER_MARGIN

var _is_in_scoring_zone = false
var _half_zone_width = 0.0 
var _direction = -1

var can_move = true
var score_percentage := 0.0
var distance_from_center := 0.0

func _ready():
	speed = SPEED_INCREASE * (GameManager.current_level + 1)
	
	# Define posição inicial aleatória no eixo X
	var random_x = randf_range(SCREEN_LIMIT_LEFT, SCREEN_LIMIT_RIGHT)
	global_position.x = random_x

	if _scoring_zone:
		var collision_shape = _scoring_zone.get_node("CollisionShape2D")
		_half_zone_width = collision_shape.shape.size.x / 2.0
	else:
		print_debug("ERRO: A 'Scoring Zone' não foi definida no Inspetor!")

func _physics_process(_delta):
	if Input.is_action_just_pressed("space"): 
		distance_from_center = abs(self.global_position.x - _scoring_zone.global_position.x)
		score_percentage = clamp(1 - (distance_from_center / _half_zone_width), 0, 1)
		var points_added = int(MAX_SCORE_PER_HIT * score_percentage)
		GameManager.update_score(points_added)
		_level.is_win = true
	if not can_move: 
		return
	velocity.x = _direction * speed
	move_and_slide()

	if _direction == -1 and global_position.x <= SCREEN_LIMIT_LEFT:
		_direction = 1
	elif _direction == 1 and global_position.x >= SCREEN_LIMIT_RIGHT:
		_direction = -1

func _on_digital_reader_body_entered(body: Node2D) -> void:
	if self == body:
		_is_in_scoring_zone = true

func _on_digital_reader_body_exited(body: Node2D) -> void:
	if self == body:
		_is_in_scoring_zone = false
