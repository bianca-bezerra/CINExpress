extends Control
## Tela "Você sabia?" que aparece antes da partida. Enquanto a intro carrega,
## uma CIN é "impressa" no centro (o progresso do carregamento) e uma
## curiosidade aparece numa caixa de diálogo. Quando tudo termina, o jogador
## confirma para começar.

const CENA_INTRO := "res://scenes/intro_scene.tscn"
const Curiosidades = preload("res://scripts/dados/curiosidades.gd")

const ALTURA_CIN := 64.0

## Tempo mínimo da "impressão" da CIN, mesmo que a intro carregue antes
@export var duracao_minima_carregamento := 2.0
## Caracteres por segundo do efeito de digitação
@export var velocidade_digitacao := 60.0

@onready var texto: Label = %Texto
@onready var status: Label = %Status
@onready var aviso: Label = %Aviso
@onready var cin_impressa: Control = %CinImpressa
@onready var cartao: Control = %Cartao
@onready var sombra: ColorRect = %Sombra
@onready var scanner: ColorRect = %Scanner
@onready var brilho: ColorRect = %Brilho
@onready var seta: Polygon2D = %Seta
@onready var nome_cin: Label = %NomeCin

## Fila compartilhada entre partidas: só repete depois de mostrar todas
static var _fila: Array[String] = []

var _tempo := 0.0
var _progresso := 0.0
var _digitacao: Tween
var _carregou := false
var _pronto := false
var _saindo := false
var _seta_y := 0.0
var _escala_cartao := Vector2.ONE


func _ready() -> void:
	aviso.visible = false
	seta.visible = false
	brilho.modulate.a = 0.0
	_seta_y = seta.position.y
	_escala_cartao = cartao.scale
	_atualizar_impressao(0.0)
	nome_cin.text = _nome_para_cin()
	ResourceLoader.load_threaded_request(CENA_INTRO)

	texto.text = _proxima_curiosidade()
	texto.visible_ratio = 0.0
	_digitacao = create_tween()
	_digitacao.tween_property(texto, "visible_ratio", 1.0, texto.text.length() / velocidade_digitacao)


## Nome do jogador para escrever na CIN. Se o nome todo não couber na linha,
## usa só o primeiro nome (e o Label corta o que ainda passar da linha).
func _nome_para_cin() -> String:
	var nome := str(PlayerManager._current_player_data.get("name", "")).strip_edges().to_upper()
	if nome.is_empty():
		return "CIDADÃO"
	var fonte := nome_cin.get_theme_font("font")
	var tamanho := nome_cin.get_theme_font_size("font_size")
	var cabe := func(t: String) -> bool:
		return fonte.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho).x <= nome_cin.size.x
	if not cabe.call(nome):
		nome = nome.split(" ", false)[0]
	return nome


func _proxima_curiosidade() -> String:
	if _fila.is_empty():
		_fila = Curiosidades.LISTA.duplicate()
		_fila.shuffle()
	return _fila.pop_back()


func _process(delta: float) -> void:
	_tempo += delta

	if not _pronto:
		var progresso_real := 1.0
		if not _carregou:
			var progresso := []
			match ResourceLoader.load_threaded_get_status(CENA_INTRO, progresso):
				ResourceLoader.THREAD_LOAD_IN_PROGRESS:
					progresso_real = float(progresso[0]) if not progresso.is_empty() else 0.0
				_:
					## carregou (ou falhou: aí a troca de cena carrega pelo caminho)
					_carregou = true
		_progresso = minf(_tempo / duracao_minima_carregamento, progresso_real)
		_atualizar_impressao(_progresso)
		status.text = "EMITINDO" + ".".repeat(int(_tempo * 3.0) % 4)

		if _progresso >= 1.0 and texto.visible_ratio >= 1.0:
			_ficar_pronto()
	else:
		## setinha de "continuar" quicando, como nas caixas de diálogo de RPG
		seta.position.y = _seta_y + roundf(absf(sin(_tempo * 5.0)) * -2.0)


## Revela a CIN de cima para baixo, com a linha do scanner na frente
func _atualizar_impressao(progresso: float) -> void:
	var altura := roundf(ALTURA_CIN * progresso)
	cin_impressa.size.y = altura
	sombra.size.y = altura
	scanner.position.y = altura - 1.0
	scanner.visible = progresso < 1.0


func _ficar_pronto() -> void:
	_pronto = true
	status.visible = false
	aviso.visible = true
	seta.visible = true
	AudioManager.play_sfx("score")

	## "pop" da CIN pronta, com um flash branco
	var pop := create_tween().set_parallel(true)
	pop.tween_property(cartao, "scale", _escala_cartao, 0.35).from(_escala_cartao * 1.08)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(brilho, "modulate:a", 0.0, 0.35).from(0.9)

	var piscar := create_tween().set_loops()
	piscar.tween_property(aviso, "modulate:a", 0.3, 0.5)
	piscar.tween_property(aviso, "modulate:a", 1.0, 0.5)


func _input(event: InputEvent) -> void:
	## durante o fade de entrada a troca de cena seria ignorada e a tela travaria
	if _saindo or GameManager.is_in_transition():
		return
	if event.is_action_pressed("ui_cancel"):
		_saindo = true
		GameManager.change_to_menu_scene()
		return

	var confirmou: bool = event.is_action_pressed("ui_accept") or event.is_action_pressed("space") \
		or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not confirmou:
		return
	get_viewport().set_input_as_handled()

	## Primeiro toque durante a digitação só completa o texto
	if texto.visible_ratio < 1.0:
		_digitacao.kill()
		texto.visible_ratio = 1.0
		return

	if _pronto:
		_saindo = true
		AudioManager.play_sfx("button_click")
		var intro = ResourceLoader.load_threaded_get(CENA_INTRO)
		GameManager.transition_to_scene(intro if intro is PackedScene else CENA_INTRO)
