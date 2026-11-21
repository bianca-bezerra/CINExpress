extends GameLevel

const Deck = preload("res://scripts/delivery/cin_delivery_deck.gd")
const FolderScene = preload("res://scenes/components/cin_folder.tscn")
const Portrait = preload("res://scripts/delivery/cin_portrait.gd")
const CUSTOMER_GREETINGS := [
	"Olá, quero retirar minha CIN.",
	"Olá! Vim buscar minha CIN.",
	"Oi! Vim retirar minha CIN.",
	"Olá! Posso pegar minha CIN?",
	"Oi! Minha CIN já está pronta?",
	"Olá! Vim pegar meu documento.",
	"Oi! Posso retirar meu documento?",
	"Olá! Minha CIN já chegou?",
	"Oi! Vim buscar meu documento.",
	"Olá! A minha CIN está pronta?",
	"Oi! Vim retirar meu documento.",
	"Olá! Já posso pegar minha CIN?",
	"Oi! Vim buscar a minha CIN.",
	"Olá! Meu documento está pronto?",
	"Oi! Posso buscar minha CIN?",
	"Olá! Estou aqui pela minha CIN.",
	"Oi! Minha CIN ficou pronta?",
]

@export var score_factor: float = 100.0
@export var success_duration: float = 0.5
@export_group("Gaveta")
@export var folder_row_bottom_offset := [0.0, 0.0, 3.0]
@export var folder_row_scale := [0.96, 1.0, 1.04]
@export var folder_row_spacing := [69.0, 74.0, 75.0]
@export var folder_center_x: float = 240.0
@export var card_lift: float = 18.0
@export_group("Texto")
@export var target_name_size := Vector2(80, 68)
@export var spoken_name_size := Vector2(121, 28)
@export_group("Atendimento")
@export var customer_arrival_seconds: float = 0.65
@export var customer_greeting_seconds: float = 0.35
@export var drawer_transition_seconds: float = 0.55
@export var drawer_reveal_offset: float = 6.0
@export var target_position := Vector2(240, 146)
@export var target_scale := Vector2(2.5, 2.42)

var deck = Deck.new()
var current_folder: int = 0
var _folder_nodes: Array[Node2D] = []
var _started_at: int
var _finished := false
var _practice := false
var _active := false
var _target_name: String
var _target_character: String
var _feedback_tween: Tween
var _intro_complete := false
var _arrival_sequence := 0
var _transitioning := false
var _tutorials: Array[Node2D] = []
var _tutorial_rows: Array[Node2D] = []
var _previous_assistant_visibility := true
var _hud_original_state: Dictionary = {}
var _practice_deliveries := 0
var _greetings_remaining: Array = []
var _last_greeting := ""


func _ready() -> void:
	# F6 tambm permite experimentar esta cena sem iniciar uma partida.
	_practice = GameManager.game_timer.is_stopped()
	_previous_assistant_visibility = GameManager.can_show_assistent
	GameManager.can_show_assistent = false
	_configure_hud()
	for node_name in ["Background", "Desk", "Drawer", "Dividers", "Folders", "Lid"]:
		get_node(node_name).visible = false
	for node_name in ["Title", "Target", "Speech", "FolderLabel", "Feedback", "Instructions", "Practice"]:
		get_node(node_name).visible = false
	if GameManager.delivery_bonus_active:
		_select_next_customer()
	else:
		if CharacterManager.personagem_atual.is_empty():
			CharacterManager.sortear_personagem()
		if CharacterManager.nome_atual.is_empty():
			_generate_customer_name()
		_target_name = CharacterManager.nome_atual
		_target_character = CharacterManager.personagem_atual
	_rebuild_drawer()
	$Practice.visible = false
	$TimeLabel.visible = false
	$TimeLabel.top_level = true
	$TimeLabel.position = Vector2(12, 8)
	$TimeLabel.z_index = 50
	$Target.visible = false
	$AttendantGroup.visible = false
	$AttendantGroup.position = Vector2(458, 235)
	$AttendantGroup.scale = Vector2(0.3, 0.3)
	_setup_tutorials()
	$Tutorials.visible = false
	_update_delivery_count()
	_intro_customer()


func _generate_customer_name() -> void:
	var generator = preload("res://scripts/names.gd").new()
	CharacterManager.registrar_nome_atual(generator.gerar_nome(CharacterManager.get_genero_personagem_atual(), 3))


func _select_next_customer() -> void:
	var previous_character := _target_character
	if previous_character.is_empty():
		previous_character = CharacterManager.personagem_atual
	for attempt in CharacterManager.personagens.size():
		CharacterManager.sortear_personagem()
		if CharacterManager.personagem_atual != previous_character:
			break
	_generate_customer_name()
	_target_name = CharacterManager.nome_atual
	_target_character = CharacterManager.personagem_atual


func _rebuild_drawer() -> void:
	for folder in _folder_nodes:
		$Folders.remove_child(folder)
		folder.queue_free()
	_folder_nodes.clear()
	current_folder = 0
	deck.build(_target_name, _target_character, CharacterManager.personagens, GameManager.current_level)
	$Target/Portrait.texture = Portrait.from_character(CharacterManager.get_sprite_cinza())
	$Target/Name.text = _target_name
	_fit_name($Target/Name, 12, target_name_size)
	for i in Deck.GROUPS.size():
		var folder := FolderScene.instantiate()
		folder.name = "Tray_%s" % Deck.GROUPS[i]
		$Folders.add_child(folder)
		folder.card_lift = card_lift
		folder.setup(Deck.GROUPS[i], deck.folders[i], CharacterManager.personagens)
		_folder_nodes.append(folder)
	_arrange_folders(true)
	$Arrival/Character.texture = CharacterManager.get_sprite_cinza()


func _update_delivery_count() -> void:
	var count: int = _practice_deliveries if _practice else PlayerManager.get_delivery_count()
	$DeliveredCount.text = "Entregues: %d" % count
	$DeliveredCount.visible = _practice or GameManager.delivery_bonus_active


func _exit_tree() -> void:
	_restore_hud()
	GameManager.can_show_assistent = _previous_assistant_visibility


func _configure_hud() -> void:
	if _practice:
		GameManager.set_ui_visible(false)
		return
	var hud := GameManager.get_node("GameUI")
	var wallet_sprite: CanvasItem = hud.get_node("WalletSprite")
	var wallet_label: CanvasItem = hud.get_node("WalletLabel")
	var hud_attendant: CanvasItem = hud.get_node("AttendantGroup")
	var score_label: Control = hud.get_node("ScoreLabel")
	_hud_original_state = {
		"wallet_sprite_visible": wallet_sprite.visible,
		"wallet_label_visible": wallet_label.visible,
		"attendant_modulate": hud_attendant.modulate,
		"score_position": score_label.position,
		"score_size": score_label.size,
		"score_font_size": score_label.get_theme_font_size("normal_font_size"),
		"score_had_font_override": score_label.has_theme_font_size_override("normal_font_size"),
	}
	# O painel do cidadão ocupa a área normalmente usada pela contagem de CIN.
	wallet_sprite.visible = false
	wallet_label.visible = false
	var hidden_attendant := hud_attendant.modulate
	hidden_attendant.a = 0.0
	hud_attendant.modulate = hidden_attendant
	score_label.position = Vector2(182, 1)
	score_label.size = Vector2(110, 23)
	score_label.add_theme_font_size_override("normal_font_size", 16)
	GameManager.set_ui_visible(true)


func _restore_hud() -> void:
	if _hud_original_state.is_empty():
		return
	var hud := GameManager.get_node("GameUI")
	hud.get_node("WalletSprite").visible = _hud_original_state["wallet_sprite_visible"]
	hud.get_node("WalletLabel").visible = _hud_original_state["wallet_label_visible"]
	hud.get_node("AttendantGroup").modulate = _hud_original_state["attendant_modulate"]
	var score_label: Control = hud.get_node("ScoreLabel")
	score_label.position = _hud_original_state["score_position"]
	score_label.size = _hud_original_state["score_size"]
	if _hud_original_state["score_had_font_override"]:
		score_label.add_theme_font_size_override("normal_font_size", _hud_original_state["score_font_size"])
	else:
		score_label.remove_theme_font_size_override("normal_font_size")
	_hud_original_state.clear()


func _setup_tutorials() -> void:
	var shortcuts := [
		{"keys": ["arrow_left", "arrow_rigth"], "caption": "Pastas", "position": Vector2(57, 251)},
		{"keys": ["arrow_up", "arrow_down"], "caption": "CINs", "position": Vector2(185, 251)},
		{"keys": ["space", "enter"], "caption": "Entregar", "position": Vector2(306, 251)},
	]
	for shortcut in shortcuts:
		var row := Node2D.new()
		row.position = shortcut["position"]
		$Tutorials.add_child(row)
		_tutorial_rows.append(row)
		var cursor_x := 0.0
		for key in shortcut["keys"]:
			var instruction: Node2D = preload("res://scenes/components/instruction.tscn").instantiate()
			row.add_child(instruction)
			instruction.position = Vector2(cursor_x, 0)
			instruction.set_meta("key", key)
			_tutorials.append(instruction)
			cursor_x += 30.0 if key == "space" else (28.0 if key == "enter" else 13.0)
			cursor_x += 3.0
		var caption := Label.new()
		caption.text = shortcut["caption"]
		caption.position = Vector2(cursor_x + 2.0, 1)
		caption.add_theme_font_override("font", preload("res://assets/fonts/nokiafc22.ttf"))
		caption.add_theme_font_size_override("font_size", 6)
		caption.add_theme_color_override("font_outline_color", Color.BLACK)
		caption.add_theme_constant_override("outline_size", 1)
		row.add_child(caption)


func _next_customer_greeting() -> String:
	if _greetings_remaining.is_empty():
		_greetings_remaining = CUSTOMER_GREETINGS.duplicate()
		_greetings_remaining.shuffle()
		# Ao recomeçar a lista, evita repetir a última fala do ciclo anterior.
		if _greetings_remaining.size() > 1 and _greetings_remaining.back() == _last_greeting:
			_greetings_remaining.push_front(_greetings_remaining.pop_back())
	_last_greeting = str(_greetings_remaining.pop_back())
	return _last_greeting


func _intro_customer() -> void:
	_arrival_sequence += 1
	var arrival_sequence := _arrival_sequence
	$Arrival.visible = true
	$Arrival.modulate = Color.WHITE
	$Arrival/ContinueHint.visible = false
	$Tutorials.visible = false
	$Arrival/Character.position = Vector2(-36, target_position.y)
	$Arrival/Character.scale = target_scale
	$Arrival/Character.modulate.a = 0.0
	$Arrival/Bubble.modulate.a = 0.0
	$Arrival/BubbleText.modulate.a = 0.0
	$Arrival/Name.position = Vector2(165, 78)
	$Arrival/Name.size = Vector2(150, 56)
	$Arrival/BubbleText.text = ""
	$Arrival/Name.visible = false
	$Arrival/Bubble.visible = false
	$Arrival/BubbleText.visible = false
	var arrival := create_tween().set_parallel()
	arrival.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	arrival.tween_property($Arrival/Character, "position:x", target_position.x, customer_arrival_seconds)
	arrival.tween_property($Arrival/Character, "modulate:a", 1.0, customer_arrival_seconds * 0.55)
	await arrival.finished
	if not is_inside_tree():
		return
	$Arrival/Name.visible = false
	$Arrival/Bubble.visible = true
	$Arrival/BubbleText.visible = true
	$Arrival/BubbleText.text = _next_customer_greeting()
	_resize_arrival_bubble()
	var speech := create_tween().set_parallel()
	speech.tween_property($Arrival/Bubble, "modulate:a", 1.0, 0.2)
	speech.tween_property($Arrival/BubbleText, "modulate:a", 1.0, 0.2)
	speech.tween_property($Arrival/Name, "modulate:a", 1.0, 0.2)
	await speech.finished
	if not is_inside_tree():
		return
	_intro_complete = true
	await get_tree().create_timer(maxf(customer_greeting_seconds, 0.0)).timeout
	# A chegada pode terminar antes do fade do atendimento anterior.
	while is_inside_tree() and _transitioning and arrival_sequence == _arrival_sequence:
		await get_tree().process_frame
	# Ignora a espera se o jogador já avançou ou chegou outra pessoa.
	if not is_inside_tree() or arrival_sequence != _arrival_sequence or not _intro_complete or _active or _finished:
		return
	_begin_selection()


func _resize_arrival_bubble() -> void:
	var bubble: NinePatchRect = $Arrival/Bubble
	var label: Label = $Arrival/BubbleText
	var font := label.get_theme_font("font")
	var font_size := 12
	var greeting_width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var text_width := clampf(ceilf(greeting_width), 110.0, 180.0)
	var text_height := ceilf(font.get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size).y)
	# Label reserva espaço extra para a altura das linhas ao cortar o texto.
	var label_height := text_height + ceilf(font.get_height(font_size))
	var bubble_size := Vector2(text_width + 24.0, label_height + 18.0)
	bubble.position = Vector2(468.0 - bubble_size.x, 35.0)
	bubble.size = bubble_size
	label.position = bubble.position + Vector2(12, 5)
	label.size = Vector2(text_width, label_height)


func _unhandled_input(event: InputEvent) -> void:
	if _intro_complete and not _active and not _transitioning and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select") or event.is_action_pressed("space")):
		get_viewport().set_input_as_handled()
		_begin_selection()
		return
	if not _can_interact():
		return
	if event.is_action_pressed("ui_left", true):
		_select_folder(-1)
	elif event.is_action_pressed("ui_right", true):
		_select_folder(1)
	elif event.is_action_pressed("ui_up", true):
		_select_card(-1)
	elif event.is_action_pressed("ui_down", true):
		_select_card(1)
	elif (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select") or event.is_action_pressed("space")) and not event.is_echo():
		_confirm_delivery()
	else:
		return
	get_viewport().set_input_as_handled()


func _can_interact() -> bool:
	return _active and not _finished and (_practice or (GameManager.game_timer.time_left > 0.0 and not GameManager.game_timer.paused))


func _select_folder(direction: int) -> void:
	current_folder = wrapi(current_folder + direction, 0, Deck.GROUPS.size())
	_update_selection()


func _select_card(direction: int) -> void:
	deck.move_card(current_folder, direction)
	_update_selection()


func _update_selection(immediate: bool = false) -> void:
	_arrange_folders(immediate)
	$Speech/Name.text = deck.current_card(current_folder)["name"]
	_resize_speech_bubble()
	$FolderLabel.text = "%s    CIN %d/%d" % [Deck.GROUPS[current_folder], deck.selected_indices[current_folder] + 1, deck.folders[current_folder].size()]
	$Feedback.text = ""
	if _feedback_tween:
		_feedback_tween.kill()
	$Speech.modulate = Color.WHITE
	$Target/Name.text = _target_name
	$Target/Portrait.texture = Portrait.from_character(CharacterManager.get_sprite_cinza())
	$Target.visible = true


func _resize_speech_bubble() -> void:
	var label: Label = $Speech/Name
	var bubble: NinePatchRect = $Speech/Bubble
	var font := label.get_theme_font("font")
	var font_size := 12
	var padding := Vector2(24, 20)
	var max_text_width := 196.0
	var text_width := minf(font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x, max_text_width)
	text_width = maxf(56.0, ceilf(text_width))
	var text_height := ceilf(font.get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, text_width, font_size).y)
	var bubble_size := Vector2(text_width, text_height) + padding
	var right_edge := 443.0
	var bottom_edge := 231.0
	$Speech.position = Vector2(right_edge - bubble_size.x, bottom_edge - bubble_size.y)
	$Speech.size = bubble_size
	bubble.size = bubble_size
	label.position = Vector2(12, 5)
	label.add_theme_font_size_override("font_size", font_size)
	label.size = Vector2(text_width, text_height + 2.0)


func _arrange_folders(immediate: bool = false) -> void:
	var divider_bottoms := [$Dividers/Third.position.y, $Dividers/Fourth.position.y, $Dividers/Front.position.y]
	for i in _folder_nodes.size():
		var folder := _folder_nodes[i]
		var row := 2 - floori(float(i) / 3.0)
		var bounds: Rect2 = folder.closed_bounds
		var scale_factor: float = folder_row_scale[row]
		folder.scale = Vector2.ONE * scale_factor
		var slot_center: float = folder_center_x + ((i % 3) - 1) * folder_row_spacing[row]
		var row_bottom: float = divider_bottoms[row] + folder_row_bottom_offset[row]
		folder.position = Vector2(slot_center - bounds.get_center().x * scale_factor, row_bottom - bounds.end.y * scale_factor)
		var selected := i == current_folder
		folder.z_index = 10 if selected else row
		folder.show_selection(deck.selected_indices[i], selected, immediate)


func _fit_name(label: Label, initial_size: int, available_size: Vector2) -> void:
	var font := label.get_theme_font("font")
	var font_size := initial_size
	while font_size > 4:
		var text_size := font.get_multiline_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, available_size.x, font_size)
		if text_size.y <= available_size.y:
			break
		font_size -= 1
	label.add_theme_font_size_override("font_size", font_size)
	label.set_deferred("size", available_size)


func _play_delivery_success() -> void:
	var folder: Node2D = _folder_nodes[current_folder]
	var card: Node2D = folder.get_node("Cards").get_child(deck.selected_indices[current_folder])
	var badge_position := card.to_global(Vector2(75, 8))
	if $Target.visible and $Target.get_global_rect().grow(12).has_point(badge_position):
		badge_position = card.to_global(Vector2(8, 8))
	var viewport_size := get_viewport_rect().size
	badge_position.x = clampf(badge_position.x, 28.0, viewport_size.x - 28.0)
	badge_position.y = clampf(badge_position.y, 28.0, viewport_size.y - 28.0)
	$SuccessFX.global_position = badge_position
	$SuccessFX.visible = true

	var stamp: Node2D = $SuccessFX/Stamp
	var left_star: Sprite2D = $SuccessFX/StarLeft
	var right_star: Sprite2D = $SuccessFX/StarRight
	stamp.scale = Vector2(0.3, 0.3)
	stamp.rotation_degrees = -18.0
	left_star.position = Vector2(-4, -4)
	right_star.position = Vector2(4, -4)
	left_star.scale = Vector2.ZERO
	right_star.scale = Vector2.ZERO
	left_star.modulate = Color.WHITE
	right_star.modulate = Color.WHITE
	var effect := create_tween().set_parallel()
	effect.tween_property(stamp, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	effect.tween_property(stamp, "rotation_degrees", 0.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	effect.tween_property(left_star, "scale", Vector2(0.24, 0.24), 0.15).set_delay(0.04)
	effect.tween_property(right_star, "scale", Vector2(0.19, 0.19), 0.15).set_delay(0.07)
	effect.tween_property(left_star, "position", Vector2(-16, -14), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	effect.tween_property(right_star, "position", Vector2(16, -16), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	effect.tween_property(left_star, "modulate:a", 0.0, 0.17).set_delay(0.33)
	effect.tween_property(right_star, "modulate:a", 0.0, 0.17).set_delay(0.33)

	var feedback: Label = $Feedback
	feedback.pivot_offset = feedback.size / 2.0
	feedback.scale = Vector2(0.8, 0.8)
	var headline := create_tween()
	headline.tween_property(feedback, "scale", Vector2(1.08, 1.08), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	headline.tween_property(feedback, "scale", Vector2.ONE, 0.12)

	var count: Label = $DeliveredCount
	if count.visible:
		count.pivot_offset = Vector2(0, count.size.y / 2.0)
		count.scale = Vector2.ONE
		var count_tween := create_tween()
		count_tween.tween_property(count, "scale", Vector2(1.12, 1.12), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		count_tween.tween_property(count, "scale", Vector2.ONE, 0.2)
		var text_width := count.get_theme_font("font").get_string_size(count.text, HORIZONTAL_ALIGNMENT_LEFT, -1, count.get_theme_font_size("font_size")).x
		var pop_position := count.position + Vector2(ceilf(text_width) + 14.0, 0)
		var pop: Label = $DeliveryPop
		pop.position = pop_position + Vector2(0, 3)
		pop.scale = Vector2(0.8, 0.8)
		pop.modulate = Color.WHITE
		pop.visible = true
		var pop_tween := create_tween().set_parallel()
		pop_tween.tween_property(pop, "position", pop_position - Vector2(0, 6), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		pop_tween.tween_property(pop, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop_tween.tween_property(pop, "modulate:a", 0.0, 0.17).set_delay(0.33)


func _confirm_delivery() -> void:
	if not _can_interact():
		return
	if not deck.is_correct(current_folder, _target_name, _target_character):
		AudioManager.play_sfx("wrong_hit")
		if not _practice:
			PlayerManager.stop_combo()
		$Feedback.text = "Essa CIN é de outra pessoa!"
		$Speech.modulate = Color(1.0, 0.55, 0.55)
		if _feedback_tween:
			_feedback_tween.kill()
		_feedback_tween = create_tween()
		_feedback_tween.tween_property($Speech, "modulate", Color.WHITE, 0.2)
		return
	_finished = true
	var elapsed := maxf((Time.get_ticks_msec() - _started_at) / 1000.0, 1.0)
	var points := int(score_factor * (GameManager.current_level + 1) / elapsed)
	if not _practice:
		PlayerManager.add_score(points)
		if GameManager.delivery_bonus_active:
			PlayerManager.increment_delivery_count()
	else:
		_practice_deliveries += 1
	_update_delivery_count()
	$Feedback.text = "CIN entregue!"
	if _feedback_tween:
		_feedback_tween.kill()
	$Speech.modulate = Color(0.65, 1.0, 0.65)
	$Target/Portrait.texture = Portrait.from_character(CharacterManager.get_sprite_feliz())
	_play_delivery_success()
	await get_tree().create_timer(success_duration).timeout
	# O cronômetro global pode ter encerrado a partida durante o feedback.
	if not is_inside_tree() or get_tree().current_scene != self:
		return
	if _practice or (GameManager.delivery_bonus_active and GameManager.game_timer.time_left > 0.0):
		_begin_next_customer()
	elif GameManager.game_timer.time_left > 0.0:
		GameManager.change_to_next_level()


func _fade_to_cover() -> ColorRect:
	var cover := ColorRect.new()
	cover.color = Color(0, 0, 0, 0)
	cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cover.z_index = 100
	add_child(cover)
	cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fade := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade.tween_property(cover, "color:a", 1.0, drawer_transition_seconds * 0.5)
	await fade.finished
	return cover


func _fade_from_cover(cover: ColorRect) -> void:
	var fade := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	fade.tween_property(cover, "color:a", 0.0, drawer_transition_seconds * 0.5)
	await fade.finished
	if is_instance_valid(cover):
		cover.queue_free()


func _canvas_position(item: CanvasItem) -> Vector2:
	if item is Node2D:
		return (item as Node2D).position
	return (item as Control).position


func _set_canvas_position(item: CanvasItem, value: Vector2) -> void:
	if item is Node2D:
		(item as Node2D).position = value
	else:
		(item as Control).position = value


func _prepare_drawer_reveal() -> Array[Dictionary]:
	var reveal_state: Array[Dictionary] = []
	var reveal_nodes := [
		"Background", "Desk", "Drawer", "Dividers", "Folders", "Lid",
		"Title", "Target", "Speech", "FolderLabel", "Feedback", "Instructions", "Practice",
	]
	for node_name in reveal_nodes:
		var item := get_node(node_name) as CanvasItem
		var base_position := _canvas_position(item)
		var base_modulate := item.modulate
		_set_canvas_position(item, base_position + Vector2(0, drawer_reveal_offset))
		var hidden_modulate := base_modulate
		hidden_modulate.a = 0.0
		item.modulate = hidden_modulate
		reveal_state.append({
			"item": item,
			"position": base_position,
			"modulate": base_modulate,
		})
	return reveal_state


func _transition_arrival_to_drawer(reveal_state: Array[Dictionary]) -> void:
	var duration := maxf(drawer_transition_seconds, 0.1)
	var transition := create_tween().set_parallel()
	transition.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Dissolve the citizen's scene as the drawer rises into place, keeping the
	# two views on screen together instead of fading through a blank cut.
	transition.tween_property($Arrival, "modulate:a", 0.0, duration)
	transition.tween_property($Arrival/Character, "position:y", target_position.y + 4.0, duration)
	for state in reveal_state:
		var item := state["item"] as CanvasItem
		var base_modulate: Color = state["modulate"]
		var base_position: Vector2 = state["position"]
		transition.tween_property(item, "modulate:a", base_modulate.a, duration)
		transition.tween_property(item, "position:y", base_position.y, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await transition.finished
	if not is_inside_tree():
		return
	$Arrival.visible = false
	$Arrival.modulate = Color.WHITE
	$Arrival/Character.position = Vector2(target_position.x, target_position.y)
	for state in reveal_state:
		var item := state["item"] as CanvasItem
		if not is_instance_valid(item):
			continue
		_set_canvas_position(item, state["position"])
		item.modulate = state["modulate"]


func _begin_next_customer() -> void:
	if _transitioning:
		return
	_transitioning = true
	_active = false
	$Tutorials.visible = false
	var cover: ColorRect = await _fade_to_cover()
	if not is_inside_tree():
		return
	$SuccessFX.visible = false
	$DeliveryPop.visible = false
	for node_name in ["Background", "Desk", "Drawer", "Dividers", "Folders", "Lid"]:
		get_node(node_name).visible = false
	for node_name in ["Title", "Target", "Speech", "FolderLabel", "Feedback", "Instructions", "Practice"]:
		get_node(node_name).visible = false
	$AttendantGroup.visible = false
	GameManager.can_show_assistent = false
	_finished = false
	_intro_complete = false
	_select_next_customer()
	_rebuild_drawer()
	_intro_customer()
	await _fade_from_cover(cover)
	if is_inside_tree():
		_transitioning = false


func _begin_selection() -> void:
	if _transitioning or _finished:
		return
	_transitioning = true
	$Arrival/ContinueHint.visible = false
	$Tutorials.visible = false
	for tutorial in _tutorials:
		tutorial.deactivate_instruction()
	$Arrival.modulate = Color.WHITE
	for node_name in ["Background", "Desk", "Drawer", "Dividers", "Folders", "Lid"]:
		get_node(node_name).visible = true
	for node_name in ["Title", "Target", "Speech", "FolderLabel", "Feedback", "Instructions", "Practice"]:
		get_node(node_name).visible = true
	$TimeLabel.visible = false
	$AttendantGroup.visible = true
	GameManager.can_show_assistent = true
	$Practice.visible = _practice
	$Instructions.visible = false
	_update_selection(true)
	var reveal_state := _prepare_drawer_reveal()
	await _transition_arrival_to_drawer(reveal_state)
	if not is_inside_tree():
		return
	_transitioning = false
	_intro_complete = false
	_started_at = Time.get_ticks_msec()
	_active = true
	var selection_positions := [Vector2(57, 251), Vector2(185, 251), Vector2(306, 251)]
	var selection_captions := ["Pastas", "CINs", "Entregar"]
	for i in _tutorial_rows.size():
		var row := _tutorial_rows[i]
		row.position = selection_positions[i]
		row.visible = true
		var caption := row.get_child(row.get_child_count() - 1) as Label
		caption.text = selection_captions[i]
	for tutorial in _tutorials:
		tutorial.get_parent().visible = true
		tutorial.visible = true
		tutorial.setup_instruction(str(tutorial.get_meta("key")), true)
	$Tutorials.visible = true
