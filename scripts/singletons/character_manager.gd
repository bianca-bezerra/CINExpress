extends Node

var personagens = {}

var nomes_disponiveis = ["jessica","maria","sheila","antonia","julia","lule","jose","marcio","tiago","raimundo"]

var personagem_atual = ""

enum {HOMEM, MULHER}

func _ready():
	carregar_personagens()
	resetar_lista_nomes()

func carregar_personagens():
	personagens = {
		"jessica": {
			"triste": preload("res://assets/sprites/characters/jessica_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jessica_feliz.png"),
			"genero":  MULHER
		},
		"antonia": {
			"triste": preload("res://assets/sprites/characters/antonia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/antonia_feliz.png"),
			"genero":  MULHER
		},
		"sheila": {
			"triste": preload("res://assets/sprites/characters/sheila_triste.png"),
			"feliz": preload("res://assets/sprites/characters/sheila_feliz.png"),
			"genero":  MULHER
		},
		"julia": {
			"triste": preload("res://assets/sprites/characters/julia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/julia_feliz.png"),
			"genero":  MULHER
		},
		"maria": {
			"triste": preload("res://assets/sprites/characters/maria_triste.png"),
			"feliz": preload("res://assets/sprites/characters/maria_feliz.png"),
			"genero":  MULHER
		},
		"marcio": {
			"triste": preload("res://assets/sprites/characters/marcio_triste.png"),
			"feliz": preload("res://assets/sprites/characters/marcio_feliz.png"),
			"genero":  HOMEM
		},
		"raimundo": {
			"triste": preload("res://assets/sprites/characters/raimundo_triste.png"),
			"feliz": preload("res://assets/sprites/characters/raimundo_feliz.png"),
			"genero":  HOMEM
		},
		"tiago": {
			"triste": preload("res://assets/sprites/characters/tiago_triste.png"),
			"feliz": preload("res://assets/sprites/characters/tiago_feliz.png"),
			"genero":  HOMEM
		},
		"jose": {
			"triste": preload("res://assets/sprites/characters/jose_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jose_feliz.png"),
			"genero":  HOMEM
		},
		"lule": {
			"triste": preload("res://assets/sprites/characters/lule_triste.png"),
			"feliz": preload("res://assets/sprites/characters/lule_feliz.png"),
			"genero":  HOMEM
		},
	}

func resetar_lista_nomes():
	nomes_disponiveis = personagens.keys().duplicate()
	nomes_disponiveis.shuffle()

func sortear_personagem() -> String:
	if nomes_disponiveis.is_empty():	
		resetar_lista_nomes()
	
	personagem_atual = nomes_disponiveis.pop_front()
	return personagem_atual

func get_genero_personagem_atual() -> int:
	return personagens[personagem_atual]["genero"]

func get_sprite_cinza() -> Texture2D:
	return personagens[personagem_atual]["triste"]

func get_sprite_feliz() -> Texture2D:
	return personagens[personagem_atual]["feliz"]
