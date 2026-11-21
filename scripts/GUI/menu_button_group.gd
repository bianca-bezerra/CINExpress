extends VBoxContainer

## Quanto o botão focado sobe (px)
const SUBIDA := 2.0

@onready var mao: Node2D = $Mao

var current_button: Button
## Posição de repouso de cada botão, definida pelo próprio VBoxContainer.
## Guardar por botão evita que eles "escorreguem" e fiquem com espaços
## diferentes quando o foco muda rápido no meio de uma animação.
var _base_y := {}
var _tweens := {}
var _tween_mao: Tween


func _ready() -> void:
	for child in get_children():
		if child is Button:
			child.focus_entered.connect(_on_button_focus_entered.bind(child))
			child.pressed.connect(_on_button_pressed)

	current_button = $StartButton
	sort_children.connect(_guardar_posicoes)
	await get_tree().process_frame
	_guardar_posicoes()
	mao.position.y = _centro_y(current_button)


## Chamado sempre que o container reorganiza os filhos
func _guardar_posicoes() -> void:
	for child in get_children():
		if child is Button:
			_base_y[child] = child.position.y
			if child == current_button and child.has_focus():
				child.position.y -= SUBIDA


var _ac = 0
func _process(_delta: float) -> void:
	_ac += _delta
	var _dest_x = current_button.global_position.x - len(current_button.text) * 2 + 3 * sin(_ac*10)
	mao.global_position.x = lerp(mao.global_position.x, _dest_x, 0.1)


func _centro_y(button: Button) -> float:
	return _base_y.get(button, button.position.y) + button.size.y / 2


func _mover_botao(button: Button, deslocamento: float) -> void:
	if _tweens.has(button) and _tweens[button].is_valid():
		_tweens[button].kill()
	var alvo: float = _base_y.get(button, button.position.y) + deslocamento
	var tween := create_tween()
	tween.tween_property(button, "position:y", alvo, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tweens[button] = tween


func _on_button_focus_entered(button: Button) -> void:
	AudioManager.play_sfx("button_hover", randf_range(0.9, 1.1))
	if current_button != button:
		_mover_botao(current_button, 0.0)
	current_button = button
	move_mao_to_button(button)
	_mover_botao(button, -SUBIDA)


func _on_button_pressed():
	AudioManager.play_sfx("button_click")


func move_mao_to_button(button: Button) -> void:
	if _tween_mao and _tween_mao.is_valid():
		_tween_mao.kill()
	_tween_mao = create_tween()
	_tween_mao.tween_property(mao, "position:y", _centro_y(button), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
