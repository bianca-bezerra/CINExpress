extends SceneTree

## Executar com --headless --path . --script res://tests/cin_delivery_auto_tests.gd.
## Os arquivos de save são redirecionados para a pasta temporária do projeto.

var DeliveryScene
var Deck
var failures: Array[String] = []
var checks := 0


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _select_correct(scene) -> bool:
	var folder_index: int = Deck.folder_for_name(scene._target_name)
	scene.current_folder = folder_index
	for i in scene.deck.folders[folder_index].size():
		scene.deck.selected_indices[folder_index] = i
		if scene.deck.is_correct(folder_index, scene._target_name, scene._target_character):
			scene._update_selection(true)
			return true
	return false


func _run() -> void:
	var save_manager = root.get_node("SaveManager")
	var save_dir := ProjectSettings.globalize_path("res://.godot/delivery-auto-tests")
	DirAccess.make_dir_recursive_absolute(save_dir)
	save_manager._save_path = "res://.godot/delivery-auto-tests/save.json"
	save_manager._global_save = "res://.godot/delivery-auto-tests/global.json"
	var game = root.get_node("GameManager")
	var player = root.get_node("PlayerManager")
	DeliveryScene = load("res://scenes/levels/cin_delivery.tscn")
	Deck = load("res://scripts/delivery/cin_delivery_deck.gd")
	game.delivery_bonus_active = true
	game.current_level = 0
	game.game_timer.paused = false
	game.game_timer.start(20)
	player.reset_current_player_data()
	player.stop_combo()
	seed(241)

	var scene = DeliveryScene.instantiate()
	scene.customer_arrival_seconds = 0.04
	scene.customer_greeting_seconds = 0.05
	scene.drawer_transition_seconds = 0.12
	scene.success_duration = 0.08
	root.add_child(scene)
	current_scene = scene
	var arrival_deadline := Time.get_ticks_msec() + 1000
	while scene.is_inside_tree() and not scene.get_node("Arrival/BubbleText").visible and Time.get_ticks_msec() < arrival_deadline:
		await process_frame
	_check(scene.get_node("Arrival").visible and scene.get_node("Arrival/BubbleText").visible, "O cidadão aparece com sua fala")
	_check(not scene.get_node("Arrival/ContinueHint").visible and not scene.get_node("Tutorials").visible, "Chegada não pede para apertar uma tecla")
	await create_timer(0.5).timeout
	_check(scene._active and not scene.get_node("Arrival").visible and scene.get_node("Folders").visible, "Primeira busca começa sem entrada")
	_check(game.game_timer.time_left > 0 and game.game_timer.time_left < 19.9, "O cronômetro continua durante a chegada")

	var previous_character: String = scene._target_character
	_check(_select_correct(scene), "Primeira CIN correta está na gaveta")
	scene._confirm_delivery()
	await create_timer(0.85).timeout
	_check(scene._active and scene._target_character != previous_character, "Busca seguinte começa automaticamente")
	_check(player.get_delivery_count() == 1 and player.get_score() > 0, "A entrega continua contando e pontuando")

	# A fala pode terminar enquanto a transição anterior ainda está em andamento.
	scene.drawer_transition_seconds = 1.2
	scene.customer_arrival_seconds = 0.01
	scene.customer_greeting_seconds = 0.0
	scene.success_duration = 0.05
	_check(_select_correct(scene), "Segunda CIN correta está na gaveta")
	scene._confirm_delivery()
	await create_timer(2.9).timeout
	_check(scene._active and player.get_delivery_count() == 2, "Transições sobrepostas não interrompem a próxima busca")

	# Uma tecla ainda pode antecipar a transição sem dispará-la duas vezes.
	scene.drawer_transition_seconds = 0.1
	scene.customer_greeting_seconds = 0.6
	_check(_select_correct(scene), "Terceira CIN correta está na gaveta")
	scene._confirm_delivery()
	await create_timer(0.4).timeout
	_check(scene._intro_complete and not scene._active, "Fala está disponível antes da transição automática")
	var event := InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	scene._unhandled_input(event)
	await create_timer(0.25).timeout
	_check(scene._active, "Tecla opcional antecipa a busca")
	var selected_name: String = scene._target_name
	var arrival_sequence: int = scene._arrival_sequence
	await create_timer(0.7).timeout
	_check(scene._active and scene._target_name == selected_name and scene._arrival_sequence == arrival_sequence, "O temporizador anterior não repete a transição")

	game.game_timer.stop()
	current_scene = null
	scene.queue_free()
	await process_frame
	player.reset_current_player_data()
	player.stop_combo()
	game._ending_game = false
	game.delivery_bonus_active = true
	game.game_timer.paused = false
	game.game_timer.start(0.4)
	var timeout_scene = DeliveryScene.instantiate()
	timeout_scene.customer_arrival_seconds = 0.03
	timeout_scene.customer_greeting_seconds = 1.0
	root.add_child(timeout_scene)
	current_scene = timeout_scene
	await create_timer(1.5).timeout
	_check(current_scene != null and current_scene.scene_file_path == "res://scenes/results_screen.tscn", "Tempo encerrado durante a chegada abre o resultado")
	_check(player.get_score() == 0 and player.get_delivery_count() == 0, "Tempo encerrado não registra uma entrega")

	print("AUTO DELIVERY TESTS: %d checks, %d failures" % [checks, failures.size()])
	for failure in failures:
		push_error(failure)
	quit(0 if failures.is_empty() else 1)
