extends Node2D

@onready var personagem_sprite = $Personagem  
@onready var cenario = $Cenario

var posicao_inicial_x = 288 
var posicao_final_x = 515     
var posicao_y = 140

var esta_processando = false 
var tempo_salvo = 0.0

func _ready():
	if esta_processando:
		return
	esta_processando = true

	if GameManager.game_timer.time_left > 0:
		tempo_salvo = GameManager.game_timer.time_left
		GameManager.game_timer.paused = true
	
	personagem_sprite.texture = CharacterManager.get_sprite_feliz()
	personagem_sprite.position = Vector2(posicao_inicial_x, posicao_y)
	
	await get_tree().create_timer(0.8).timeout
	animar_saida()

func animar_saida():
	var tween_movimento = create_tween()
	tween_movimento.tween_property(personagem_sprite, "position:x", posicao_final_x, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var tween_bounce = create_tween()
	tween_bounce.set_loops(4)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y - 4, 0.125)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y, 0.125)
	
	tween_movimento.finished.connect(_on_saida_completa)

func _on_saida_completa():
	if not esta_processando:
		return
	
	await get_tree().create_timer(0.3).timeout
	
	if tempo_salvo > 1.0: 
		GameManager.game_timer.paused = false
		
		GameManager.primeira_rodada = false
		
		GameManager.scene_transintion_animation.play("fade_in")
		get_tree().change_scene_to_file("res://scenes/intro_scene.tscn")
		GameManager.scene_transintion_animation.play("fade_out")
	else:
		GameManager.end_game()
