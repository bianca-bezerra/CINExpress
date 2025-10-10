extends Node

var personagens = {}

var nomes_disponiveis = ["jessica","maria","sheila","antonia","julia","lule","jose","marcio","tiago","raimundo"]

var personagem_atual = ""

func _ready():
	carregar_personagens()
	resetar_lista_nomes()

func carregar_personagens():
	personagens = {
		"jessica": {
			"triste": preload("res://assets/sprites/characters/jessica_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jessica_feliz.png")
		},
		"antonia": {
			"triste": preload("res://assets/sprites/characters/antonia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/antonia_feliz.png")
		},
		"sheila": {
			"triste": preload("res://assets/sprites/characters/sheila_triste.png"),
			"feliz": preload("res://assets/sprites/characters/sheila_feliz.png")
		},
		"julia": {
			"triste": preload("res://assets/sprites/characters/julia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/julia_feliz.png")
		},
		"maria": {
			"triste": preload("res://assets/sprites/characters/maria_triste.png"),
			"feliz": preload("res://assets/sprites/characters/maria_feliz.png")
		},
		"marcio": {
			"triste": preload("res://assets/sprites/characters/marcio_triste.png"),
			"feliz": preload("res://assets/sprites/characters/marcio_feliz.png")
		},
		"raimundo": {
			"triste": preload("res://assets/sprites/characters/raimundo_triste.png"),
			"feliz": preload("res://assets/sprites/characters/raimundo_feliz.png")
		},
		"tiago": {
			"triste": preload("res://assets/sprites/characters/tiago_triste.png"),
			"feliz": preload("res://assets/sprites/characters/tiago_feliz.png")
		},
		"jose": {
			"triste": preload("res://assets/sprites/characters/jose_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jose_feliz.png")
		},
		"lule": {
			"triste": preload("res://assets/sprites/characters/lule_triste.png"),
			"feliz": preload("res://assets/sprites/characters/lule_feliz.png")
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

func get_sprite_cinza() -> Texture2D:
	return personagens[personagem_atual]["triste"]

func get_sprite_feliz() -> Texture2D:
	return personagens[personagem_atual]["feliz"]
