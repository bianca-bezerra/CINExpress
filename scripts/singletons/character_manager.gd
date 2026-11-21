extends Node

var personagens = {}
var nomes_disponiveis = []
var personagem_atual = ""
var nome_atual: String = ""
var cins_para_entrega: Array[Dictionary] = []

enum { HOMEM, MULHER }

func _ready():
	randomize()
	carregar_personagens()
	resetar_lista_nomes()


func carregar_personagens():
	personagens = {
		"jessica": {
			"triste": preload("res://assets/sprites/characters/jessica_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jessica_feliz.png"),
			"genero": MULHER
		},
		"antonia": {
			"triste": preload("res://assets/sprites/characters/antonia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/antonia_feliz.png"),
			"genero": MULHER
		},
		"sheila": {
			"triste": preload("res://assets/sprites/characters/sheila_triste.png"),
			"feliz": preload("res://assets/sprites/characters/sheila_feliz.png"),
			"genero": MULHER
		},
		"julia": {
			"triste": preload("res://assets/sprites/characters/julia_triste.png"),
			"feliz": preload("res://assets/sprites/characters/julia_feliz.png"),
			"genero": MULHER
		},
		"maria": {
			"triste": preload("res://assets/sprites/characters/maria_triste.png"),
			"feliz": preload("res://assets/sprites/characters/maria_feliz.png"),
			"genero": MULHER
		},
		"marcio": {
			"triste": preload("res://assets/sprites/characters/marcio_triste.png"),
			"feliz": preload("res://assets/sprites/characters/marcio_feliz.png"),
			"genero": HOMEM
		},
		"raimundo": {
			"triste": preload("res://assets/sprites/characters/raimundo_triste.png"),
			"feliz": preload("res://assets/sprites/characters/raimundo_feliz.png"),
			"genero": HOMEM
		},
		"tiago": {
			"triste": preload("res://assets/sprites/characters/tiago_triste.png"),
			"feliz": preload("res://assets/sprites/characters/tiago_feliz.png"),
			"genero": HOMEM
		},
		"jose": {
			"triste": preload("res://assets/sprites/characters/jose_triste.png"),
			"feliz": preload("res://assets/sprites/characters/jose_feliz.png"),
			"genero": HOMEM
		},
		"lule": {
			"triste": preload("res://assets/sprites/characters/lule_triste.png"),
			"feliz": preload("res://assets/sprites/characters/lule_feliz.png"),
			"genero": HOMEM
		},
	}


func resetar_lista_nomes():
	nomes_disponiveis = personagens.keys().duplicate()
	nomes_disponiveis.shuffle()


func sortear_personagem() -> String:
	nome_atual = ""
	if nomes_disponiveis.is_empty():
		resetar_lista_nomes()
	
	personagem_atual = nomes_disponiveis.pick_random()
	nomes_disponiveis.erase(personagem_atual)
	
	return personagem_atual


func registrar_nome_atual(nome: String) -> void:
	nome_atual = nome


func limpar_cins_para_entrega() -> void:
	cins_para_entrega.clear()


func registrar_cin_concluida() -> void:
	if personagem_atual.is_empty() or nome_atual.is_empty():
		return
	cins_para_entrega.append({"name": nome_atual, "character": personagem_atual})


func selecionar_cin_para_entrega(personagem_anterior: String = "") -> bool:
	if cins_para_entrega.is_empty():
		return false
	var indice := -1
	for i in cins_para_entrega.size():
		if cins_para_entrega[i]["character"] != personagem_anterior:
			indice = i
			break
	if indice < 0:
		return false
	var cin: Dictionary = cins_para_entrega.pop_at(indice)
	personagem_atual = cin["character"]
	registrar_nome_atual(cin["name"])
	return true


func get_genero_personagem_atual() -> int:
	return personagens[personagem_atual]["genero"]


func get_sprite_cinza() -> Texture2D:
	return personagens[personagem_atual]["triste"]


func get_sprite_feliz() -> Texture2D:
	return personagens[personagem_atual]["feliz"]
