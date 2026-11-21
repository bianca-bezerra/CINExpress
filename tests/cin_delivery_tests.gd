extends Node
## Executar em uma instncia separada: este teste redireciona todos os saves.

const Deck = preload("res://scripts/delivery/cin_delivery_deck.gd")
const Delivery = preload("res://scenes/levels/cin_delivery.tscn")
var failures: Array[String] = []
var checks: int = 0


func _enter_tree() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot/delivery-tests"))
	SaveManager._save_path = "res://.godot/delivery-tests/save.json"
	SaveManager._global_save = "res://.godot/delivery-tests/global.json"


func _ready() -> void:
	await get_tree().process_frame
	seed(417)
	_test_decks()
	_test_correct_positions()
	await _test_typing_handoff()
	await _test_navigation_and_delivery()
	await _test_timeout()
	await _test_long_names_and_practice()
	GameManager.game_timer.stop()
	await get_tree().create_timer(1.0).timeout
	print("DELIVERY TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	get_tree().quit.call_deferred(0 if failures.is_empty() else 1)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _test_decks() -> void:
	_check(GameManager.current_run == ["type", "finger", "cam"], "Sequência dos minigames principais")
	_check(Deck.folder_for_name("") == -1, "Nome vazio no pertence a uma pasta")
	for sample in ["\u00c1lvaro", "\u00c2ngela", "\u00c9rica", "\u00cdtalo", "\u00d3scar", "\u00darsula", "\u00c7lia", "Yara", "Zacarias"]:
		_check(Deck.folder_for_name(sample) >= 0, "Inicial com acento: " + sample)
	for level in [0, 1, 2, 3, 4, 20]:
		for target in ["\u00c1lvaro Silva", "\u00cdtalo Lima", "\u00darsula Santos", "Zilda Oliveira"]:
			var deck = Deck.new()
			deck.build(target, "jessica", CharacterManager.personagens, level)
			var expected_count: int = 2 if level < 2 else (3 if level < 4 else 4)
			var correct_count := 0
			var names_seen := {}
			for i in Deck.GROUPS.size():
				_check(deck.folders[i].size() == expected_count, "Quantidade de carteiras na rodada %d" % level)
				var portraits_seen := {}
				for card in deck.folders[i]:
					_check(Deck.folder_for_name(card["name"]) == i, "Carteira na pasta correta")
					_check(not names_seen.has(card["name"]), "Nome completo nico")
					_check(not portraits_seen.has(card["character"]), "Retrato único dentro da pasta")
					names_seen[card["name"]] = true
					portraits_seen[card["character"]] = true
					if card["name"] == target and card["character"] == "jessica":
						correct_count += 1
			_check(correct_count == 1, "Exatamente uma CIN correta")
	var limited_characters := {
		"jessica": CharacterManager.personagens["jessica"],
		"jose": CharacterManager.personagens["jose"],
	}
	var limited_deck = Deck.new()
	limited_deck.build("Ana Lima", "jessica", limited_characters, 20)
	for folder in limited_deck.folders:
		_check(folder.size() == 2, "Quantidade respeita os retratos disponíveis")
		_check(folder[0]["character"] != folder[1]["character"], "Pasta limitada não repete retratos")
	CharacterManager.registrar_nome_atual("Nome anterior")
	CharacterManager.sortear_personagem()
	_check(CharacterManager.nome_atual.is_empty(), "Prximo cidado limpa o nome")


func _test_correct_positions() -> void:
	var targets := ["Ágata Lima Silva", "Ítalo Lima", "Yara Oliveira", "Zilda Souza"]
	for level in [0, 2, 4]:
		var deck = Deck.new()
		var count: int = Deck.cards_per_folder(level)
		var positions_in_cycle := {}
		for round_index in count * 4:
			var target: String = targets[round_index % targets.size()]
			deck.build(target, "jessica", CharacterManager.personagens, level)
			var folder_index: int = Deck.folder_for_name(target)
			var correct_index := -1
			for card_index in deck.folders[folder_index].size():
				var card: Dictionary = deck.folders[folder_index][card_index]
				if card["name"] == target and card["character"] == "jessica":
					correct_index = card_index
					break
			_check(correct_index >= 0, "CIN correta está presente na pasta")
			if correct_index >= 0:
				_check(not positions_in_cycle.has(correct_index), "Posições variam em cada ciclo")
				positions_in_cycle[correct_index] = true
				_check(deck.is_correct(folder_index, target, "jessica") == (correct_index == 0), "Seleção inicial corresponde à posição sorteada")
				deck.move_card(folder_index, correct_index)
				_check(deck.is_correct(folder_index, target, "jessica"), "Navegação encontra a CIN correta")
			if (round_index + 1) % count == 0:
				_check(positions_in_cycle.size() == count, "Todas as posições aparecem no ciclo")
				positions_in_cycle.clear()
	var single_character := {"jessica": CharacterManager.personagens["jessica"]}
	var single_deck = Deck.new()
	for round_index in 3:
		single_deck.build("Ágata Lima Silva", "jessica", single_character, 20)
		for folder in single_deck.folders:
			_check(folder.size() == 1, "Pasta respeita o único retrato disponível")
		_check(single_deck.is_correct(Deck.folder_for_name("Ágata Lima Silva"), "Ágata Lima Silva", "jessica"), "CIN única continua correta")


func _mount(scene: Node) -> void:
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene


func _clear_scene() -> void:
	var scene := get_tree().current_scene
	get_tree().current_scene = null
	if scene and scene != self:
		scene.queue_free()
	await get_tree().process_frame


func _test_typing_handoff() -> void:
	GameManager.current_level = 0
	GameManager.current_game_level = 1
	CharacterManager.personagem_atual = "jessica"
	GameManager.game_timer.start(60)
	var typing = load("res://scenes/levels/type_quickly.tscn").instantiate()
	_mount(typing)
	var original_name: String = typing._current_name
	_check(CharacterManager.nome_atual == original_name, "Digitao registra o nome no gerenciador")
	typing._round_start_time = Time.get_ticks_msec() - 1000
	typing._on_text_changed(original_name)
	await get_tree().create_timer(2.15).timeout
	var delivery := get_tree().current_scene
	_check(delivery.scene_file_path == "res://scenes/levels/cin_delivery.tscn", "Digitao avana para entrega")
	_check(delivery._target_name == original_name, "Entrega preserva o nome digitado")
	_check(delivery._target_character == "jessica", "Entrega preserva o cidado")
	await _clear_scene()


func _press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await get_tree().process_frame


func _new_delivery() -> Node:
	CharacterManager.personagem_atual = "jessica"
	CharacterManager.registrar_nome_atual("\u00c1gata Lima Silva")
	GameManager.current_game_level = 2
	GameManager.game_timer.paused = false
	GameManager.game_timer.start(60)
	var scene := Delivery.instantiate()
	_mount(scene)
	await get_tree().create_timer(scene.customer_arrival_seconds + 0.3).timeout
	_check(scene._intro_complete and not scene._active, "Cidado apresenta o nome antes da busca")
	_check(not scene.get_node("Arrival/BubbleText").text.is_empty(), "Cidado fala antes da busca")
	_check(not scene.get_node("Folders").visible and not scene.get_node("Target").visible, "Gaveta aguarda a fala do cidadao")
	if "--visual" in OS.get_cmdline_user_args() and checks < 1600:
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/delivery-tests/arrival.png")
	scene._begin_selection()
	await get_tree().create_timer(scene.drawer_transition_seconds + 0.05).timeout
	return scene


func _test_navigation_and_delivery() -> void:
	var scene: Node = await _new_delivery()
	await _press("ui_left")
	_check(scene.current_folder == 8, "Pastas fazem navegao circular")
	await _press("ui_right")
	await _press("ui_down")
	var remembered: int = scene.deck.selected_indices[0]
	await _press("ui_right")
	await _press("ui_left")
	_check(scene.deck.selected_indices[0] == remembered, "Pasta mantm sua ltima carteira")
	for i in 20:
		await _press("ui_down")
	await get_tree().create_timer(0.15).timeout
	var folder: Node = scene._folder_nodes[scene.current_folder]
	var highlighted := 0
	for card in folder.cards:
		if card.get_node("Highlight").visible:
			highlighted += 1
			_check(is_equal_approx(card.position.y, card._rest_position.y - card.lift), "CIN destacada fica elevada")
	_check(highlighted == 1, "Exatamente uma CIN destacada aps navegao rpida")
	_check(scene.get_node("Speech/Name").text == scene.deck.current_card(scene.current_folder)["name"], "Balo acompanha seleo")
	scene.current_folder = 1
	scene._update_selection()
	PlayerManager.multiplier = 3
	var before: float = PlayerManager.get_score()
	var time_before: float = GameManager.game_timer.time_left
	await _press("space")
	_check(not scene._finished and PlayerManager.multiplier == 1, "Erro quebra combo e permite continuar")
	_check(PlayerManager.get_score() == before, "Erro no pontua")
	_check(GameManager.game_timer.time_left > time_before - 0.5, "Erro no desconta tempo extra")
	_select_correct(scene)
	scene._started_at = Time.get_ticks_msec() - 2000
	var count_before: float = PlayerManager.get_cin_count()
	await _press("space")
	var after: float = PlayerManager.get_score()
	_check(after > before, "Acerto pontua")
	scene._confirm_delivery()
	_check(PlayerManager.get_score() == after, "Confirmao repetida no duplica pontos")
	await get_tree().create_timer(0.4).timeout
	_check(get_tree().current_scene.scene_file_path == "res://scenes/levels/finger_scene.tscn", "Entrega avana para digital")
	_check(PlayerManager.get_cin_count() == count_before, "Entrega no duplica contagem de CIN")
	var finger := get_tree().current_scene
	finger.can_win = true
	finger._on_win_timer_timeout()
	await get_tree().process_frame
	await get_tree().process_frame
	var camera := get_tree().current_scene
	_check(camera.scene_file_path == "res://scenes/levels/cam_level.tscn", "Digital avana para foto")
	camera.player_winned = true
	camera.handle_win()
	await camera.get_node("AnimationPlayer").animation_finished
	await get_tree().process_frame
	await get_tree().process_frame
	_check(get_tree().current_scene.scene_file_path == "res://scenes/outro_scene.tscn", "Foto conclui atendimento")
	_check(PlayerManager.get_cin_count() == count_before + 1, "Atendimento completo conta uma CIN")
	await _clear_scene()


func _select_correct(scene: Node) -> void:
	scene.current_folder = Deck.folder_for_name(scene._target_name)
	for i in scene.deck.folders[scene.current_folder].size():
		scene.deck.selected_indices[scene.current_folder] = i
		if scene.deck.is_correct(scene.current_folder, scene._target_name, scene._target_character):
			break
	scene._update_selection()


func _test_timeout() -> void:
	for confirm_first in [false, true]:
		var scene: Node = await _new_delivery()
		if confirm_first:
			_select_correct(scene)
			scene._confirm_delivery()
		var score_before: float = PlayerManager.get_score()
		GameManager.game_timer.start(0.05)
		await get_tree().create_timer(0.5).timeout
		_check(get_tree().current_scene.scene_file_path == "res://scenes/results_screen.tscn", "Timeout encerra durante busca/feedback")
		_check(PlayerManager.get_score() == score_before, "Timeout no pontua novamente")
		_check(GameManager.current_game_level == 0, "Timeout no avana para outro minigame")
		var saved: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SaveManager._save_path))
		_check(saved.has("dashboard") and saved.has("player_count"), "Save mantm o formato existente")
		await get_tree().create_timer(6.0).timeout
		await _clear_scene()


func _test_long_names_and_practice() -> void:
	GameManager.current_level = 4
	var scene: Node = await _new_delivery()
	var long_name := "\u00c1gata " + "Nascimento ".repeat(19).strip_edges()
	scene.get_node("Target/Name").text = long_name
	scene._fit_name(scene.get_node("Target/Name"), 12, scene.target_name_size)
	scene.get_node("Speech/Name").text = long_name
	scene._fit_name(scene.get_node("Speech/Name"), 14, scene.spoken_name_size)
	await get_tree().process_frame
	for path in ["Target/Name", "Speech/Name"]:
		var label: Label = scene.get_node(path)
		_check(label.get_line_count() * label.get_line_height() <= label.size.y, "Nome longo cabe em " + path)
		var bounds: Vector2 = scene.target_name_size if path == "Target/Name" else scene.spoken_name_size
		_check(label.size.y <= bounds.y, "Nome longo no expande o balo/painel em " + path)
	scene.get_node("Target/Name").text = scene._target_name
	scene._fit_name(scene.get_node("Target/Name"), 12, scene.target_name_size)
	scene._update_selection()
	GameManager.set_ui_visible(false)
	if "--visual" in OS.get_cmdline_user_args():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(960, 540))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/delivery-tests/preview.png")
		DisplayServer.window_set_size(Vector2i(480, 270))
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/delivery-tests/native.png")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.godot/delivery-tests/fullscreen.png")
	await _clear_scene()
	GameManager.game_timer.stop()
	GameManager.set_ui_visible(false)
	scene = Delivery.instantiate()
	_mount(scene)
	_check(scene._practice, "F6 permite prvia com cronmetro parado")
	_select_correct(scene)
	var score_before: float = PlayerManager.get_score()
	scene._confirm_delivery()
	_check(PlayerManager.get_score() == score_before, "Prvia no altera pontuao")
	await _clear_scene()
