extends GameLevel
class_name CertidaoLevel

const CAMINHO_PECAS = "res://assets/sprites/certidao/padrao_%d/peca_%d.png"
const TEX_ANTIGA = preload("res://assets/sprites/certidao/certidao_antiga.png")
const TEX_NOVA = preload("res://assets/sprites/certidao/certidao_nova.png")

const LIMITES_TELA = Rect2(0, 0, 480, 270)

const CELULA := 6.0
const TENTATIVAS_POSICAO := 60
const PESO_SILHUETA := 1.0
const PESO_PEDACO := 1.5
const PESO_EVITAR := 10.0

const DURACAO_CHEGADA := 0.35
const DURACAO_CHEGADA_INTERVALO := 0.06

const SOMBRA_COR := Color(0, 0, 0, 0.22)
const SOMBRA_OFFSET := Vector2(1, 1)
const SOMBRA_OFFSET_ERGUIDO := Vector2(2, 3)

const DIFICULDADE = [
	{"pedacos": 3, "tolerancia": 18.0},
	{"pedacos": 3, "tolerancia": 16.0},
	{"pedacos": 4, "tolerancia": 14.0},
	{"pedacos": 5, "tolerancia": 12.0},
]

const GRUPOS = {
	1: {
		3: [[[1,2],[3,5],[4,6]], [[1,5],[2,3],[4,6]], [[1,5],[2,4],[3,6]]],
		4: [[[1,2],[3,4],[5],[6]], [[1,2],[3],[4],[5,6]], [[1,3],[2],[4],[5,6]]],
		5: [[[1],[2],[3,6],[4],[5]], [[1,2],[3],[4],[5],[6]], [[1],[2],[3,4],[5],[6]]],
	},
	2: {
		3: [[[1,3],[2,4],[5,6]], [[1,2],[3,6],[4,5]], [[1,2],[3,4],[5,6]]],
		4: [[[1,4],[2],[3,6],[5]], [[1,2],[3,6],[4],[5]], [[1,3],[2],[4,5],[6]]],
		5: [[[1],[2],[3],[4,5],[6]], [[1,3],[2],[4],[5],[6]], [[1],[2],[3],[4],[5,6]]],
	},
	3: {
		3: [[[1,2],[3,4],[5,6]], [[1,3],[2,6],[4,5]], [[1,2],[3,5],[4,6]]],
		4: [[[1,2],[3],[4,5],[6]], [[1,3],[2,4],[5],[6]], [[1,4],[2,6],[3],[5]]],
		5: [[[1],[2],[3],[4,6],[5]], [[1],[2],[3,4],[5],[6]], [[1],[2],[3,5],[4],[6]]],
	},
}
const TODAS_SOLTAS = [[1],[2],[3],[4],[5],[6]]

@export var PONTOS := 100
@export var ESCALA := 2.0
@export var AREA_INICIAL := Rect2(24, 38, 440, 224)
@export var ZONAS_EVITAR: Array[Rect2] = [Rect2(420, 81, 60, 108), Rect2(381, 136, 85, 114)]
@export var DISTANCIA_MINIMA_INICIAL := 40.0

@onready var floating_text_scene = preload("res://scenes/components/floating_text.tscn")
@onready var alvo_marker: Marker2D = $Alvo
@onready var silhueta: Sprite2D = $Silhueta
@onready var grupos_node: Node2D = $Grupos
@onready var sombras_encaixadas: Node2D = $SombrasEncaixadas
@onready var certidao_final: Sprite2D = $CertidaoFinal
@onready var particulas: CPUParticles2D = $Particulas
@onready var som_encaixe: AudioStreamPlayer = $SomEncaixe
@onready var instrucao = $Instruction

var _phrases = ["Novinha!", "Atualizada!", "Show!", "Prontinho!"]

var _rodada := 0
var _tolerancia := 10.0
var _alvo := Vector2.ZERO

var _grupo_arrastado: Node2D = null
var _offset_arraste := Vector2.ZERO
var _grupos_restantes := 0
var _terminou := false
var _chegando := false

var _imagens := {}


func _ready() -> void:
	_rodada = GameManager.current_level

	var cfg = DIFICULDADE[clampi(_rodada, 0, DIFICULDADE.size() - 1)]
	_tolerancia = cfg["tolerancia"]
	_alvo = (alvo_marker.global_position - _tamanho_certidao() / 2.0).round()

	silhueta.global_position = _alvo
	silhueta.scale = Vector2.ONE * ESCALA
	silhueta.visible = true
	instrucao.setup_instruction("mouse_left")

	var centro = _centro_certidao()
	certidao_final.global_position = centro
	certidao_final.scale = Vector2.ONE * ESCALA
	certidao_final.visible = false
	particulas.global_position = centro
	particulas.emission_rect_extents = _tamanho_certidao() / 2.0

	var padrao = randi_range(1, 3)
	var combinacao = TODAS_SOLTAS if cfg["pedacos"] >= 6 else GRUPOS[padrao][cfg["pedacos"]].pick_random()
	_criar_grupos(padrao, combinacao)


func _criar_grupos(padrao: int, combinacao: Array) -> void:
	var grupos: Array[Node2D] = []

	for ids in combinacao:
		var grupo = Node2D.new()
		grupo.name = "Grupo_%s" % "_".join(ids.map(func(i): return str(i)))

		var bbox := Rect2()
		var texturas = ids.map(func(id): return load(CAMINHO_PECAS % [padrao, id]))

		for tex in texturas:
			var sombra = Sprite2D.new()
			sombra.centered = false
			sombra.texture = tex
			sombra.modulate = SOMBRA_COR
			sombra.position = SOMBRA_OFFSET
			sombra.set_meta("sombra", true)
			grupo.add_child(sombra)

		for tex in texturas:
			var peca = Sprite2D.new()
			peca.centered = false
			peca.texture = tex
			grupo.add_child(peca)

			var usado = _imagem(peca.texture).get_used_rect()
			bbox = bbox.merge(usado) if bbox.has_area() else usado

		grupo.set_meta("bbox", bbox)
		grupo.set_meta("travado", false)
		grupo.scale = Vector2.ONE * ESCALA
		grupos_node.add_child(grupo)
		grupos.append(grupo)

	var posicoes = _sortear_posicoes(grupos)
	_grupos_restantes = combinacao.size()
	_animar_chegada(grupos, posicoes)


func _animar_chegada(grupos: Array[Node2D], posicoes: Array) -> void:
	_chegando = true
	var ultimo: Tween = null

	for i in grupos.size():
		var grupo = grupos[i]
		var destino: Vector2 = posicoes[i]
		var bbox: Rect2 = grupo.get_meta("bbox")
		var pivo = bbox.get_center() * ESCALA
		var alvo_pivo = destino + pivo

		var inicio_pivo = Vector2(alvo_pivo.x + randf_range(-40.0, 40.0), -(bbox.size * ESCALA).length() / 2.0)
		var giro_inicial = randf_range(-0.5, 0.5)

		var aplicar = func(t: float):
			var p = inicio_pivo.lerp(alvo_pivo, t)
			grupo.rotation = lerpf(giro_inicial, 0.0, t)
			grupo.global_position = p - pivo.rotated(grupo.rotation)
		aplicar.call(0.0)

		var tween = create_tween()
		tween.tween_interval(i * DURACAO_CHEGADA_INTERVALO)
		tween.tween_method(aplicar, 0.0, 1.0, DURACAO_CHEGADA).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func():
			grupo.rotation = 0.0
			grupo.global_position = destino)
		ultimo = tween

	if ultimo:
		await ultimo.finished
	_chegando = false


func _sortear_posicoes(grupos: Array[Node2D]) -> Array:
	var colunas = ceili(LIMITES_TELA.size.x / CELULA)
	var linhas = ceili(LIMITES_TELA.size.y / CELULA)
	var peso := PackedFloat32Array()
	peso.resize(colunas * linhas)
	_marcar_celulas(peso, colunas, Rect2(_alvo, _tamanho_certidao()), PESO_SILHUETA)
	for z in ZONAS_EVITAR:
		_marcar_celulas(peso, colunas, z, PESO_EVITAR)
	if GameManager.current_level == 0:
		_marcar_celulas(peso, colunas, Rect2(instrucao.global_position - Vector2(6, 6), Vector2(26, 30)), PESO_EVITAR)

	var amostras := []
	for g in grupos:
		amostras.append(_amostras_do_grupo(g))
	var ordem = range(grupos.size())
	ordem.sort_custom(func(a, b): return amostras[a].size() > amostras[b].size())

	var posicoes := []
	posicoes.resize(grupos.size())
	for i in ordem:
		var bbox: Rect2 = grupos[i].get_meta("bbox")
		var pos_min = AREA_INICIAL.position - bbox.position * ESCALA
		var pos_max = (AREA_INICIAL.end - bbox.end * ESCALA).max(pos_min)

		var melhor = pos_min if pos_min.distance_to(_alvo) > pos_max.distance_to(_alvo) else pos_max
		var menor_custo := INF
		for t in TENTATIVAS_POSICAO:
			var p = Vector2(randf_range(pos_min.x, pos_max.x), randf_range(pos_min.y, pos_max.y)).round()
			if p.distance_to(_alvo) < DISTANCIA_MINIMA_INICIAL:
				continue
			var custo := 0.0
			for a in amostras[i]:
				custo += peso[_indice_celula(p + a, colunas, linhas)]
			if custo < menor_custo:
				menor_custo = custo
				melhor = p
				if custo == 0.0:
					break

		posicoes[i] = melhor
		for a in amostras[i]:
			peso[_indice_celula(melhor + a, colunas, linhas)] += PESO_PEDACO

	return posicoes


func _amostras_do_grupo(grupo: Node2D) -> PackedVector2Array:
	var pontos := PackedVector2Array()
	var passo = CELULA / ESCALA
	var tam = TEX_ANTIGA.get_size()
	var ty = passo / 2.0
	while ty < tam.y:
		var tx = passo / 2.0
		while tx < tam.x:
			for peca: Sprite2D in _pecas(grupo):
				if _imagem(peca.texture).get_pixel(int(tx), int(ty)).a > 0.5:
					pontos.append(Vector2(tx, ty) * ESCALA)
					break
			tx += passo
		ty += passo
	return pontos


func _indice_celula(ponto: Vector2, colunas: int, linhas: int) -> int:
	var cx = clampi(floori(ponto.x / CELULA), 0, colunas - 1)
	var cy = clampi(floori(ponto.y / CELULA), 0, linhas - 1)
	return cy * colunas + cx


func _marcar_celulas(peso: PackedFloat32Array, colunas: int, rect: Rect2, valor: float) -> void:
	var linhas = peso.size() / colunas
	for cy in linhas:
		for cx in colunas:
			var centro = (Vector2(cx, cy) + Vector2(0.5, 0.5)) * CELULA
			if rect.has_point(centro):
				peso[cy * colunas + cx] += valor


func _tamanho_certidao() -> Vector2:
	return TEX_ANTIGA.get_size() * ESCALA


func _centro_certidao() -> Vector2:
	return _alvo + _tamanho_certidao() / 2.0


func _retangulo_visivel(bbox: Rect2, pos: Vector2) -> Rect2:
	return Rect2(pos + bbox.position * ESCALA, bbox.size * ESCALA)


func _limitar_posicao(pos: Vector2, bbox: Rect2, limites: Rect2) -> Vector2:
	var minimo = limites.position - bbox.position * ESCALA
	var maximo = (limites.end - bbox.end * ESCALA).max(minimo)
	return pos.clamp(minimo, maximo)


func _imagem(tex: Texture2D) -> Image:
	if not _imagens.has(tex):
		var img = tex.get_image()
		if img.is_compressed():
			img.decompress()
		_imagens[tex] = img
	return _imagens[tex]


func _input(event: InputEvent) -> void:
	if _terminou or _chegando:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_tentar_pegar()
		else:
			_soltar()
	elif event is InputEventMouseMotion and _grupo_arrastado:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_soltar()
		else:
			_arrastar()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _grupo_arrastado:
		_soltar()


func _tentar_pegar() -> void:
	var mouse = get_global_mouse_position()

	for i in range(grupos_node.get_child_count() - 1, -1, -1):
		var grupo: Node2D = grupos_node.get_child(i)
		if grupo.get_meta("travado"):
			continue
		if _clicou_no_grupo(grupo, mouse):
			_grupo_arrastado = grupo
			_offset_arraste = grupo.global_position - mouse
			grupos_node.move_child(grupo, -1)
			_posicionar_sombras(grupo, SOMBRA_OFFSET_ERGUIDO)
			get_viewport().set_input_as_handled()
			return


func _clicou_no_grupo(grupo: Node2D, mouse: Vector2) -> bool:
	for peca: Sprite2D in _pecas(grupo):
		var local = peca.to_local(mouse)
		var img = _imagem(peca.texture)
		var x = floori(local.x)
		var y = floori(local.y)
		if x < 0 or y < 0 or x >= img.get_width() or y >= img.get_height():
			continue
		if img.get_pixel(x, y).a > 0.5:
			return true
	return false


func _pecas(grupo: Node2D) -> Array:
	return grupo.get_children().filter(func(n): return not n.has_meta("sombra"))


func _sombras(grupo: Node2D) -> Array:
	return grupo.get_children().filter(func(n): return n.has_meta("sombra"))


func _posicionar_sombras(grupo: Node2D, offset: Vector2) -> void:
	for sombra in _sombras(grupo):
		sombra.position = offset


func _arrastar() -> void:
	var bbox: Rect2 = _grupo_arrastado.get_meta("bbox")
	var nova = get_global_mouse_position() + _offset_arraste

	nova = _limitar_posicao(nova, bbox, LIMITES_TELA)

	_grupo_arrastado.global_position = nova.round()


func _soltar() -> void:
	if not _grupo_arrastado:
		return
	var grupo = _grupo_arrastado
	_grupo_arrastado = null
	_posicionar_sombras(grupo, SOMBRA_OFFSET)

	if grupo.global_position.distance_to(_alvo) <= _tolerancia:
		_encaixar(grupo)


func _encaixar(grupo: Node2D) -> void:
	grupo.set_meta("travado", true)
	grupo.global_position = _alvo
	for sombra in _sombras(grupo):
		sombra.reparent(sombras_encaixadas)
		sombra.global_position = _alvo + SOMBRA_OFFSET * ESCALA
	grupos_node.move_child(grupo, 0)
	var encaixados = grupos_node.get_child_count() - _grupos_restantes
	som_encaixe.pitch_scale = 1.0 + 0.06 * encaixados
	som_encaixe.play()

	var pivo: Vector2 = grupo.get_meta("bbox").get_center() * ESCALA
	var aplicar_escala = func(s: float):
		grupo.scale = Vector2.ONE * s * ESCALA
		grupo.global_position = _alvo + pivo * (1.0 - s)

	grupo.modulate = Color(1.6, 1.6, 1.6)
	var tween = create_tween().set_parallel(true)
	tween.tween_method(aplicar_escala, 1.15, 1.0, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(grupo, "modulate", Color.WHITE, 0.15)

	_grupos_restantes -= 1
	if _grupos_restantes <= 0:
		_completar()


func _completar() -> void:
	_terminou = true
	instrucao.visible = false
	PlayerManager.add_score(PONTOS)

	var floating_text: RichTextLabel = floating_text_scene.instantiate()
	floating_text.global_position = $FeedbackMarker.global_position
	floating_text.text = "[shake][rainbow]%s[/rainbow][/shake]" % _phrases.pick_random()
	add_child(floating_text)

	await get_tree().create_timer(0.15).timeout
	_animar_transformacao()


func _animar_transformacao() -> void:
	grupos_node.visible = false
	sombras_encaixadas.visible = false
	silhueta.visible = false
	certidao_final.texture = TEX_ANTIGA
	certidao_final.scale = Vector2.ONE * ESCALA
	certidao_final.visible = true
	var mat: ShaderMaterial = certidao_final.material
	mat.set_shader_parameter("flash", 0.0)
	mat.set_shader_parameter("brilho_pos", -1.0)

	var tween = create_tween().set_parallel(true)

	tween.tween_property(certidao_final, "scale", Vector2.ONE * ESCALA * 1.1, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/flash", 1.0, 0.3)

	tween.chain().tween_callback(_trocar_para_nova)

	tween.tween_property(mat, "shader_parameter/flash", 0.0, 0.35)
	tween.tween_property(certidao_final, "scale", Vector2.ONE * ESCALA, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.chain().tween_property(mat, "shader_parameter/brilho_pos", 1.2, 0.45).from(-0.2)

	tween.chain().tween_interval(0.15)
	tween.chain().tween_callback(_terminar_fase)


func _trocar_para_nova() -> void:
	certidao_final.texture = TEX_NOVA
	particulas.restart()


func _terminar_fase() -> void:
	GameManager.change_to_next_level()
