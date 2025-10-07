extends CharacterBody2D

@export var speed = 0
@onready var _scoring_zone: Area2D = $"../digital_reader"
@onready var _level = $".."


const FINGER_INCLINATION_DEG = 25
const FINGER_MARGIN = 150
const SPEED_INCREASE = 300.0
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

func _try():
	GameManager.game_timer.paused = true
	var _tween = get_tree().create_tween()
	var _initial_pos = position.y
	var _dest = position.y - 10
	_tween.set_trans(Tween.TRANS_SPRING)
	_level.spawn_motivation_text()
	can_move = false
	if _level.win_timer.is_stopped():
		_level.win_timer.start(1.2)
	if _is_in_scoring_zone:
		_initial_pos = _dest
		_level.can_win = true
		score_percentage = clamp(1 - (distance_from_center / _half_zone_width), 0, 1)
		var points_added = int(MAX_SCORE_PER_HIT * score_percentage)
		PlayerManager.add_score(points_added)
		_tween.tween_property(self, "position:y", _initial_pos, 0.5)
		return
	_tween.tween_property(self, "position:y", _initial_pos, 1.3).from(_dest)


func _physics_process(_delta):	
	distance_from_center = abs(self.global_position.x - _scoring_zone.global_position.x)
	score_percentage = clamp(1 - (distance_from_center / _half_zone_width), 0, 1)
	if Input.is_action_just_pressed("space"):                   
		if can_move:
			_try()
	if not can_move: 
		return
	
	velocity.x = _direction * speed
	move_and_slide()
	
	var _center_dist = self.global_position.x - _scoring_zone.global_position.x;
	var _new_rotation = FINGER_INCLINATION_DEG * ( 1 + _center_dist) / _scoring_zone.global_position.x;
	rotation = lerp(rotation, deg_to_rad(_new_rotation), 0.2);

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
