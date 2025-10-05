extends CharacterBody2D

@export var speed = 800.0
@onready var scoring_zone: Area2D = $"../digital_reader"
@onready var level = $".."

var direction = -1
const LIMIT_LEFT = -800.0
const LIMIT_RIGHT = 800.0
const SPEED_INCREASE = 300.0
const MAX_SCORE_PER_HIT = 100

var is_in_scoring_zone = false
var half_zone_width = 0.0 

func _ready():	
	if scoring_zone:
		var collision_shape = scoring_zone.get_node("CollisionShape2D")
		half_zone_width = collision_shape.shape.size.x / 2.0
	else:
		print_debug("ERRO: A 'Scoring Zone' não foi definida no Inspetor!")

func _physics_process(_delta):
	if Input.is_action_just_pressed("space"): 
		if is_in_scoring_zone:
			var distance_from_center = abs(self.global_position.x - scoring_zone.global_position.x)
			
			var score_percentage = (distance_from_center / half_zone_width)
			var points_added = int(MAX_SCORE_PER_HIT * score_percentage)
			
			GameManager.update_score(points_added)
			
			if speed >= 0:
				speed += SPEED_INCREASE
			else:
				speed -= SPEED_INCREASE
				
			level.win_count += 1
			print("PONTOU! +", points_added, " | Pontuação Total: ", GameManager.get_score(), " | Nova Velocidade: ", speed)

	self.velocity.x = direction * speed
	self.move_and_slide()

	if direction == -1 and global_position.x <= LIMIT_LEFT:
		direction = 1
	elif direction == 1 and global_position.x >= LIMIT_RIGHT:
		direction = -1

func _on_digital_reader_body_entered(body: Node2D) -> void:
	if self == body:
		is_in_scoring_zone = true

func _on_digital_reader_body_exited(body: Node2D) -> void:
	if self == body:
		is_in_scoring_zone = false
