extends Node

signal score_chaged(new_score: float)

var names: Array[String] = [
	"Ana Carolina de Souza", "Bruno dos Santos Oliveira", "Carlos Eduardo Pereira",
	"Daniela Ferreira Lima", "Eduardo Almeida Costa", "Fernanda Gonçalves Ribeiro",
	"Gustavo Rodrigues Martins", "Helena Barbosa Gomes", "Igor de Castro Alves"
]

var _player_score: int = 0
var player_name: String = ""

var current_level := 0

## O total que o ciclo de jogo TOTAL vai durar
@export var total_game_duration := 15

## Timer do ciclo total de jogo
@onready var game_timer = $GameTimer

var _can_show_game_ui = false

func _process(_delta: float) -> void:
	$GameUI.visible = _can_show_game_ui

func update_score(add_score: int):
	_player_score += add_score
	score_chaged.emit(add_score)
	
func start_game():
	_can_show_game_ui = true
	game_timer.start(total_game_duration)

func end_game():
	pass

func get_score():
	return _player_score

func _on_game_timer_timeout() -> void:
	_can_show_game_ui = false
	get_tree().change_scene_to_file("res://scenes/levels/title_scene.tscn")
