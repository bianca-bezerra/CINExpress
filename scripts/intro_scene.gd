extends Node2D

@onready var personagem_sprite = $Personagem
@onready var cenario = $Cenario
@onready var balao_fala = $BalaoFala 
@onready var balao_imagem = $BalaoImagem 
@onready var texto_instrucao = $TextoInstrucao
@onready var balao_atendente_fala = $BalaoAtendenteFala
@onready var balao_atendente_imagem = $BalaoAtendenteImagem
@onready var atendente = $AttendantGroup

var posicao_inicial_x = 59
var posicao_final_x = 288
var posicao_y = 140

var pode_iniciar = false
var jogo_iniciado = false

func _enter_tree() -> void:
	GameManager.set_ui_visible(false)

func _ready():
	CharacterManager.sortear_personagem()
	personagem_sprite.texture = CharacterManager.get_sprite_cinza()
	personagem_sprite.position = Vector2(posicao_inicial_x, posicao_y)
	
	balao_imagem.visible = false
	balao_atendente_fala.visible = false
	balao_atendente_imagem.visible = false
	
	if balao_fala:
		balao_fala.visible = false
	if texto_instrucao:
		texto_instrucao.visible = false
	
	if not GameManager.primeira_rodada and GameManager.game_timer:
		GameManager.game_timer.paused = false
	
	if GameManager.primeira_rodada:
		animar_entrada_com_falas()
	else:
		animar_entrada_sem_falas()

func animar_entrada_com_falas():
	var tween_movimento = create_tween()
	tween_movimento.tween_property(personagem_sprite, "position:x", posicao_final_x, 1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var tween_bounce = create_tween()
	tween_bounce.set_loops(6)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y - 4, 0.125)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y, 0.125)
	
	tween_movimento.finished.connect(_on_animacao_completa_com_falas)
	
func mostrar_fala_atendente():
	if not balao_atendente_fala:
		return
	
	balao_atendente_fala.visible = true
	balao_atendente_fala.modulate.a = 0
	
	balao_atendente_imagem.visible = true
	balao_atendente_imagem.modulate.a = 0
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.parallel()
	tween.tween_property(balao_atendente_imagem, "modulate:a", 1.0, 0.3)
	tween.tween_property(balao_atendente_fala, "modulate:a", 1.0, 0.3)
	
	await tween.finished
	

func _on_animacao_completa_com_falas():
	await get_tree().create_timer(0.3).timeout
	
	mostrar_fala_personagem()
	await get_tree().create_timer(1.0).timeout
	
	if texto_instrucao:
		texto_instrucao.visible = true
		animar_piscar_texto()
	
	pode_iniciar = true

func animar_entrada_sem_falas():
	var tween_movimento = create_tween()
	tween_movimento.tween_property(personagem_sprite, "position:x", posicao_final_x, 0.7)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var tween_bounce = create_tween()
	tween_bounce.set_loops(4)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y - 4, 0.125)
	tween_bounce.tween_property(personagem_sprite, "position:y", posicao_y, 0.125)
	
	tween_movimento.finished.connect(_on_animacao_completa_sem_falas)

func _on_animacao_completa_sem_falas():

	await get_tree().create_timer(0.5).timeout
	iniciar_jogo_sem_intro()

func mostrar_fala_personagem():
	if not balao_fala:
		return
		
	balao_imagem.visible = true	
	balao_fala.visible = true
	balao_fala.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(balao_fala, "modulate:a", 1.0, 0.3)
	
	await tween.finished

func animar_piscar_texto():
	if not texto_instrucao:
		return
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(texto_instrucao, "modulate:a", 0.3, 0.5)
	tween.tween_property(texto_instrucao, "modulate:a", 1.0, 0.5)
	await tween.finished
	
func atentente_surgindo_esquerda():
	var tween_movimento = create_tween()
	atendente.in_idle = false
	atendente.sprite.animation = "default"
	atendente.sprite.frame = 1
	tween_movimento.tween_property(atendente, "position:x", 55, 1.0)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
	
	await tween_movimento.finished
		

func _input(event):
	if pode_iniciar and not jogo_iniciado:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select"):
			iniciar_jogo()

func iniciar_jogo():
	AudioManager.play_sfx("button_click")
	jogo_iniciado = true
	pode_iniciar = false
	
	if texto_instrucao:
		texto_instrucao.visible = false
	
	await atentente_surgindo_esquerda()
	await mostrar_fala_atendente()
	await get_tree().create_timer(0.35).timeout
	
	if balao_fala:
		balao_fala.visible = false
	
	GameManager.game_timer.start(GameManager.total_game_duration)
	
	GameManager.primeira_rodada = false
	
	GameManager.change_to_next_level()

func iniciar_jogo_sem_intro():
	GameManager.change_to_next_level()
