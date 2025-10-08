extends Node
signal game_saved

var _save_path = "user://savegame.save"

var game_data = {
	"dashboard": [],
	"player_count" : 0
}

## Salva os dados presentes em "game_data"
func save_game():
	var file = FileAccess.open(_save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(game_data))
		file.close()
		game_saved.emit()
	else:
		print("Error saving game.")

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
				print("Game loaded successfully.")
			else:
				print("Error parsing save data.")
		else:
			print("Error opening save file.")
	else:
		print("No save file found.")

## Reseta o save salvando nenhuma informação
func reset_save():
	game_data = {
		"dashboard": [],
		"player_count" : 0
	}
	save_game()
	
