extends Node

var current_level := 0

@export var total_game_duration := 60
var can_show_assistent := true

@onready var game_timer: Timer = $GameTimer
@onready var scene_transintion_animation = $SceneTransitionAnimation/AnimationPlayer

var _can_show_game_ui = false

var game_levels  = {
	"type": preload("res://scenes/levels/type_quickly.tscn"),
	"finger": preload("res://scenes/levels/finger_scene.tscn"),
	"cam": preload("res://scenes/levels/cam_level.tscn"),
	"certidao": preload("res://scenes/levels/certidao_level.tscn"),
}

var current_game_level = 0
var current_run = ["certidao", "type", "finger", "cam"]

var primeira_rodada := true



func _ready() -> void:
	PlayerManager.reset_current_player_data()


func _process(_delta: float) -> void:
	$GameUI.visible = _can_show_game_ui
	

func start_game():	
	_can_show_game_ui = false
	primeira_rodada = true
	game_timer.stop()
	game_timer.paused = false
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")
	scene_transintion_animation.play("fade_out")
	
func change_to_ranking():
	get_tree().change_scene_to_file("res://scenes/ranking_scene.tscn")
	
func change_to_credits():
	get_tree().change_scene_to_file("res://scenes/credits_scene.tscn")

func change_to_next_level():
	_can_show_game_ui = true
	if current_game_level >= len(current_run):
		finalizar_rodada()
		return
	
	var scene_name = current_run[current_game_level]
	
	var scene = game_levels[scene_name]
	current_game_level += 1
	
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_packed(scene)
	scene_transintion_animation.play("fade_out")


func finalizar_rodada():
	_can_show_game_ui = false
	current_game_level = 0
	PlayerManager.increment_cin_count()
	current_level += 1
	get_tree().change_scene_to_file("res://scenes/outro_scene.tscn")
	_can_show_game_ui = true


func change_to_username_scene():
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/levels/username_scene.tscn")
	scene_transintion_animation.play("fade_out")
	

func change_to_menu_scene():
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/levels/menu_scene.tscn")
	scene_transintion_animation.play("fade_out")


func end_game():
	game_timer.stop()
	game_timer.paused = false
	
	_can_show_game_ui = false
	current_level = 0
	current_game_level = 0
	
	primeira_rodada = true
	
	PlayerManager.save_current_player()
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/results_screen.tscn")
	scene_transintion_animation.play("fade_out")


func get_dashboard():
	return SaveManager.game_data["dashboard"]


func _on_game_timer_timeout() -> void:
	end_game()


func _enter_tree() -> void:
	SaveManager.load_game()
	

func _exit_tree() -> void:
	SaveManager.save_game()


func toggle_ui():
	_can_show_game_ui = !_can_show_game_ui

func set_ui_visible(visible:bool):
	_can_show_game_ui = visible
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_delete"):
		get_tree().reload_current_scene()
