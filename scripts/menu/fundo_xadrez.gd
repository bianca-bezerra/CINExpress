class_name FundoXadrez
extends Control
## Fundo xadrez rolando na diagonal, usado no menu e na tela "Você sabia?"

@export var tamanho := 16
@export var cor_a := Color("ffffff")
@export var cor_b := Color("eef4fe")
## Velocidade (px/s) da rolagem
@export var velocidade := 10.0

var _tempo := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_tempo += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), cor_a)
	var passo := tamanho * 2
	var deslocamento := fmod(_tempo * velocidade, passo)
	var linhas := int(size.y / tamanho) + 3
	var colunas := int(size.x / tamanho) + 3
	for linha in linhas:
		for coluna in colunas:
			if (linha + coluna) % 2 == 0:
				continue
			var pos := Vector2(coluna, linha) * tamanho - Vector2.ONE * passo + Vector2.ONE * deslocamento
			draw_rect(Rect2(pos.round(), Vector2.ONE * tamanho), cor_b)
