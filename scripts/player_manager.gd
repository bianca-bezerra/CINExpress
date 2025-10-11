extends Node

signal score_chaged(new_score: float)

signal cin_increased(new_num: float)

signal combo_stopped()

var _current_player_data = {
	"id": 0,
	"name": "",
	"score": 0.0,
	"cin_count": 0.0,
	"best_combo": 0.0,
}

var multiplier := 1

var _scores_in_a_row := 0

@export var COMBO_INIT_SCORES_IN_A_ROW = 4

@onready var combo_timer = $ComboTimer

func _process(_delta: float) -> void:
	combo_timer.paused = GameManager.game_timer.paused

func reset_current_player_data():
	_current_player_data = {
		"id" : 0,
		"name": "",
		"score": 0.0,
		"cin_count": 0.0,
		"best_combo": 0.0,
		"started_at": "",
		"ended_at": "",
	}

func register_new_player(player_name: String):
	_current_player_data["name"] = player_name
	_current_player_data["id"] = Time.get_ticks_msec()
	
func _handle_combo():
	_scores_in_a_row += 1
	if _scores_in_a_row >= COMBO_INIT_SCORES_IN_A_ROW:
		var timer_duration = 5 / (multiplier/5.0)
		multiplier += 1
		combo_timer.start(timer_duration)
		if multiplier > _current_player_data["best_combo"]:
			_current_player_data["best_combo"] = multiplier
		
func add_score(score: float):
	var _pitch_scale = clamp(pow(1.05, multiplier), 1.0, 2.0)
	AudioManager.play_sfx("score", _pitch_scale)
	print("adicionando %.2f" % score)
	var _new_score = score * PlayerManager.multiplier
	_current_player_data["score"] += _new_score
	_handle_combo()
	score_chaged.emit(score)
		
func stop_combo():
	combo_timer.stop()
	_scores_in_a_row = 0
	multiplier = 1
	combo_stopped.emit()

func increment_cin_count():
	_current_player_data["cin_count"] +=1
	AudioManager.play_sfx("cin_increase")
	cin_increased.emit()

func save_current_player():
	SaveManager.game_data["dashboard"].append(_current_player_data)
	SaveManager.save_game()

func register_start_time(start_time_timestamp: String):
	_current_player_data["started_at"] = start_time_timestamp

func register_end_time(end_time_timestamp: String):
	_current_player_data["ended_at"] = end_time_timestamp

func get_score():
	return _current_player_data["score"]

func get_cin_count():
	return _current_player_data["cin_count"]
	
func get_combo_timer_value():
	return combo_timer.time_left

func get_combo_timer_total_time():
	return combo_timer.wait_time

func get_player_by_name(player_name: String) -> Dictionary:
	var players = GameManager.get_dashboard()
	var player_found = players.filter(func(player): return player["name"].to_lower() == player_name.to_lower())
	
	if not player_found.is_empty():
		return player_found[0]
	else:
		return {}

func get_player_by_id(player_id: int) -> Dictionary:
	var players = GameManager.get_dashboard()
	var player_found = players.filter(func(player): return player.get("id") == player_id)
	if not player_found.is_empty():
		return player_found[0]
	else:
		return {}

func delete_player(player_id: int) -> bool:
	var dashboard = SaveManager.game_data["dashboard"]
	var original_size = dashboard.size()
	var new_dashboard = dashboard.filter(func(player): return player.get("id") != player_id)

	if new_dashboard.size() < original_size:
		SaveManager.game_data["dashboard"] = new_dashboard
		SaveManager.save_game()
		print("Jogador com ID %d foi deletado com sucesso." % player_id)
		return true
	else:
		print("Jogador com ID %d não encontrado." % player_id)
		return false


func edit_player(player_id: int, new_data: Dictionary) -> bool:
	var dashboard = SaveManager.game_data["dashboard"]
	var player_index = -1

	for i in range(dashboard.size()):
		if dashboard[i].get("id") == player_id:
			player_index = i
			break

	if player_index != -1:
		var player_to_edit = dashboard[player_index]

		for key in new_data:
			if player_to_edit.has(key):
				player_to_edit[key] = new_data[key]
			else:
				print("Aviso: Tentando editar um campo inexistente ('%s') para o jogador ID %d" % [key, player_id])

		SaveManager.game_data["dashboard"][player_index] = player_to_edit
		SaveManager.save_game()

		print("Jogador com ID %d foi editado com sucesso." % player_id)
		return true
	else:
		print("Jogador com ID %d não encontrado para editar." % player_id)
		return false


func _on_combo_timer_timeout() -> void:
	stop_combo()
