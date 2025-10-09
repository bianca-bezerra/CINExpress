extends Node
signal score_chaged(new_score: float)
signal cin_increased(new_num: float)

signal combo_stopped()

var _current_player_data = {
	"name": "",
	"score": 0.0,
	"cin_count": 0.0
}

var multiplier := 1
var _scores_in_a_row = 0

@onready var combo_timer = $ComboTimer

func reset_current_player_data():
	_current_player_data = {
		"name": "",
		"score": 0.0,
		"cin_count": 0.0
	}
	

func register_new_player(player_name: String):
	_current_player_data["name"] = player_name
	
func _handle_combo():
	_scores_in_a_row += 1
	if _scores_in_a_row >= 3:
		var timer_duration = 5 / (multiplier/5.0)
		multiplier += 1
		combo_timer.start(timer_duration)
		
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

func get_score():
	return _current_player_data["score"]

func get_cin_count():
	return _current_player_data["cin_count"]
	
func get_combo_timer_value():
	return combo_timer.time_left

func get_combo_timer_total_time():
	return combo_timer.wait_time

func _on_combo_timer_timeout() -> void:
	stop_combo()
