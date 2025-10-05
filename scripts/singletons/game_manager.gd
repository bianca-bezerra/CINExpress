extends Node

signal score_chaged(new_score: float)

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
		"Benjamin Constant de Albuquerque Sampaio e Mello", "Maria do Carmo de Medeiros Brandão Cavalcanti",
		"João Evangelista de Assis Chateaubriand Bandeira", "Antônio de Pádua e Bragança de Orleans e Silva",
		"Teresinha do Menino Jesus de Gusmão e Vasconcelos", "Luís Inácio de Gonzaga e Proença de Almeida"
	]
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
