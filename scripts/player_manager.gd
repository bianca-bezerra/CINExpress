extends Node
signal score_chaged(new_score: float)

var _current_player_data = {
	"name": "",
	"score": 0,
	"cin_count": 0
}

func reset_current_player_data():
	_current_player_data = {
		"name": "",
		"score": 0,
		"cin_count": 0
	}

func register_new_player(player_name: String):
	_current_player_data["name"] = player_name

func add_score(score: float):
	AudioManager.play_sfx("combo_sound")
	print("adicionando %.2f" % score)
	_current_player_data["score"] += score
	score_chaged.emit(score)

func increment_cin_count():
	_current_player_data["cin_count"] +=1

func save_current_player():
	SaveManager.game_data["dashboard"].append(_current_player_data)
	SaveManager.save_game()
	reset_current_player_data()

func get_score():
	return _current_player_data["score"]

func get_cin_count():
	return _current_player_data["cin_count"]
	
