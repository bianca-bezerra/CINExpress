extends Node
signal game_saved

var _save_path = "user://savegame.save"
var _global_save = "user://savegame_global.save"

var game_data = {
	"dashboard": [],
	"player_count" : 0
}

var _global_data: Array[Dictionary] = []

## Salva os dados presentes em "game_data"
func save_game():
	_normalize_profile_names()
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_data))
		file.close()
		game_saved.emit()
	else:
		print("Error saving game.")

func save_global_data():
	var file = FileAccess.open(_global_save, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_global_data))
		file.close()
		game_saved.emit()
	else:
		print("Error saving game.")

func load_global_data():
	if FileAccess.file_exists(_global_save):
		var file = FileAccess.open(_global_save, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var parsed_data = JSON.parse_string(json_string)
			if parsed_data is Dictionary:
				_global_save = parsed_data
				print("Game loaded successfully.")
			else:
				print("Error parsing save data.")
		else:
			print("Error opening save file.")
	else:
		print("No save file found.")

## Carrega os dados do arquivo de save
func load_game():
	if FileAccess.file_exists(_save_path):
		var file = FileAccess.open(_save_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var parsed_data = JSON.parse_string(json_string)
			if parsed_data is Dictionary:
				game_data = parsed_data
				_normalize_profile_names()
				print("Game loaded successfully.")
			else:
				print("Error parsing save data.")
		else:
			print("Error opening save file.")
	else:
		print("No save file found.")

## Reseta o save salvando nenhuma informação
func reset_save():
	
	## Salva estatísticas globais da run:
	load_global_data()
	_global_data.append({
		"game_data" : game_data,
		"timestamp" : Time.get_datetime_string_from_system()
	})
	save_global_data()
	_global_data = []
	
	## Reseta o save local salvando vazio
	game_data = {
		"dashboard": [],
		"player_count" : 0
	}
	save_game()
	


func _normalize_profile_names() -> void:
	for profile in game_data.get("dashboard", []):
		if profile is Dictionary and profile.has("name"):
			profile["name"] = str(profile["name"]).strip_edges().to_upper()
