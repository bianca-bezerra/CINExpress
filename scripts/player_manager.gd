extends Node

## Emitido quando há mudança de score (chamado em @add_score)
signal score_chaged(new_score: float)

## Emitido quando há incremento de cin_count (chamado em @add_score)
signal cin_increased(new_num: float)

## Emitido quando há a interrupção do combo
signal combo_stopped()

var _current_player_data = {
	"name": "",
	"score": 0.0,
	"cin_count": 0.0
}

## Multiplicador levado em conta durante o combo
var multiplier := 1

## Quantas vezes o jogador acertou seguidas
var _scores_in_a_row := 0

## Controla quantas vezes seguidas o jogador deve acertar para iniciar os combos
@export var COMBO_INIT_SCORES_IN_A_ROW = 4

@onready var combo_timer = $ComboTimer


func _process(_delta: float) -> void:
	combo_timer.paused = GameManager.game_timer.paused

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
	if _scores_in_a_row >= COMBO_INIT_SCORES_IN_A_ROW:
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
