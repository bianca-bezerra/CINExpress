extends Node

signal game_finished

## Lista de nomes utilizados no minigame "type quickly", organizados por ordem de dificuldade
var names := [
	[
		"Julia Ferraz Lima", "Lucas Costa Souza", "Maria Clara Dias",
		"Ana Luiza Chaves", "João Pedro Barros", "Sofia Ribeiro Alves",
		"Carlos Eduardo Reis", "Livia Gomes Pinto"
	],
	[
		"Laura Fernandes dos Reis", "Bernardo Martins Ribeiro", "Valentina Gonçalves de Almeida",
		"Samuel da Conceição e Silva", "Heloísa de Jesus Medeiros", "Lorenzo de Paula e Santos",
		"Cecília Nogueira de Barros", "Benjamin de Assis Tavares"
	],
	[
		"Giovanna de Oliveira Lima e Costa", "Matheus Ribeiro de Carvalho e Souza",
		"Manuela dos Santos Pereira Gomes", "Felipe de Almeida Castro e Silva",
		"Larissa Barbosa de Medeiros Lima", "Vinicius de Moraes e Albuquerque",
		"Esther de Campos Freire e Paiva"
	],
	[
		"Guilherme de Albuquerque Cavalcanti Neto", "Gabriela Nogueira de Vasconcelos Menezes",
		"Thiago dos Anjos de Assunção Guimarães", "Rafaela da Cunha Sampaio e Medeiros",
		"Francisco de Borja e Drummond de Andrade", "Júlia de Magalhães e Vasconcelos Pires",
		"Rodrigo de Gusmão e Resende de Oliveira"
	],
	[
		"Alexandre Magno de Oliveira e Vasconcelos", "Carolina Francisca Peixoto de Abreu e Lima",
		"Leonardo de Castro Marins da Anunciação", "Fernanda do Espírito Santo de Guimarães e Prado",
		"Sebastião de Albuquerque Brandão e Cavalcanti", "Isadora da Anunciação de Assis e Medeiros"
	],
	[
	"Benjamin Constant de Albuquerque Sampaio e Mello",
	"Maria do Carmo de Medeiros Brandão Cavalcanti",
	"João Evangelista de Assis Chateaubriand Bandeira",
	"Antônio de Pádua e Bragança de Orleans e Silva",
	"Teresinha do Menino Jesus de Gusmão e Vasconcelos",
	"Luís Inácio de Gonzaga e Proença de Almeida",
	"Francisco José de Guimarães e Azevedo Couto",
	"Pedro de Alcântara Fonseca de Menezes e Alencar",
	"Isabel Cristina Leopoldina de Bragança e Bourbon",
	"Joaquim José da Silva Xavier de Albuquerque e Lacerda",
	"Carlos Alberto de Andrade e Vasconcelos Guimarães",
	"Ana Carolina de Gusmão e Resende de Oliveira e Couto",
	"José Bonifácio de Andrada e Silva de Magalhães",
	"Beatriz de Castro Alves e Menezes de Albuquerque",
	"Fernando de Noronha e Vasconcelos Pires de Almeida",
	"Catarina de Siena e Gusmão da Frota Pessoa",
	"Manuel Inácio da Silva Alvarenga e Peixoto"
]
]


var current_level := 0

## O total que o ciclo de jogo TOTAL vai durar
@export var total_game_duration := 15

## Timer do ciclo total de jogo
@onready var game_timer = $GameTimer
@onready var scene_transintion_animation = $SceneTransitionAnimation/AnimationPlayer

var _can_show_game_ui = false

var game_levels  = {
	"type": preload("res://scenes/levels/type_quickly.tscn"),
	"finger": preload("res://scenes/levels/finger_scene.tscn"),
	"cam": preload("res://scenes/levels/cam_level.tscn") 
}

var current_game_level = 0
var current_run = ["type", "finger", "cam"]

func _ready() -> void:
	PlayerManager.reset_current_player_data()

func _process(_delta: float) -> void:
	$GameUI.visible = _can_show_game_ui	
	
func start_game():
	_can_show_game_ui = true
	game_timer.start(total_game_duration)
	change_to_next_level()


func change_to_next_level():
	if current_game_level >= len(current_run):
		PlayerManager.increment_cin_count()
		current_level += 1
		current_game_level = 0
	var scene_name = current_run[current_game_level]		
	var scene = game_levels[scene_name]
	current_game_level += 1
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_packed(scene)
	scene_transintion_animation.play("fade_out")


func change_to_username_scene():
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/levels/username_scene.tscn")
	scene_transintion_animation.play("fade_out")


func change_to_menu_scene():
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/levels/menu_scene.tscn")
	scene_transintion_animation.play("fade_out")

func change_to_ranking():
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/ranking_scene.tscn")
	scene_transintion_animation.play("fade_out")
	
func get_game_timer():
	return $GameTimer

func end_game():
	_can_show_game_ui = false
	current_level = 0
	current_game_level = 0	
	game_timer.stop()
	PlayerManager.save_current_player()
	scene_transintion_animation.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/results_screen.tscn")
	scene_transintion_animation.play("fade_out")
	game_finished.emit()


func get_dashboard():
	return SaveManager.game_data["dashboard"]

func _on_game_timer_timeout() -> void:
	end_game();

func _enter_tree() -> void:
	SaveManager.load_game()

func _exit_tree() -> void:
	SaveManager.save_game()

## Botões secretos (sigilo total)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_down"):
		print("[Botão secreto] - Resetando Saves")
		SaveManager.reset_save()
	if event.is_action_pressed("ui_text_delete"):
		print("[Botão secreto] - Reload")
		get_tree().reload_current_scene()
