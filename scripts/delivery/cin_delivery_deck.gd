extends RefCounted
## Dados da gaveta, independentes da navegao e das animaes.

const GROUPS = ["ABC", "DEF", "GHI", "JKL", "MNO", "PQR", "STU", "VWX", "YZ"]
const Names = preload("res://scripts/names.gd")

var folders: Array[Array] = []
var selected_indices: Array[int] = []
var _names = Names.new()
var _correct_positions_by_count: Dictionary = {}


static func folder_for_name(full_name: String) -> int:
	var initial := full_name.strip_edges().left(1).to_upper()
	if initial.is_empty():
		return -1
	match initial.unicode_at(0):
		192, 193, 194, 195, 196:
			initial = "A"
		200, 201, 202, 203:
			initial = "E"
		204, 205, 206, 207:
			initial = "I"
		210, 211, 212, 213, 214:
			initial = "O"
		217, 218, 219, 220:
			initial = "U"
		199:
			initial = "C"
	for i in GROUPS.size():
		if not initial.is_empty() and initial in GROUPS[i]:
			return i
	return -1


static func cards_per_folder(level: int) -> int:
	return clampi(2 + floori(level / 2.0), 2, 4)


func _next_correct_position(count: int) -> int:
	var positions: Array = _correct_positions_by_count.get(count, [])
	if positions.is_empty():
		positions = range(count)
		positions.shuffle()
	var position: int = positions.pop_back()
	_correct_positions_by_count[count] = positions
	return position


func build(target_name: String, target_character: String, characters: Dictionary, level: int) -> void:
	folders.clear()
	selected_indices.clear()
	var used_names := {target_name: true}
	var count := mini(cards_per_folder(level), characters.size())
	var target_folder := folder_for_name(target_name)
	assert(target_folder >= 0, "O cidado precisa ter um nome com inicial A-Z.")
	assert(characters.has(target_character), "O cidadão precisa ter um retrato disponível.")
	for folder_index in GROUPS.size():
		var cards: Array = []
		var available_characters := characters.keys()
		var decoy_count := count
		if folder_index == target_folder:
			available_characters.erase(target_character)
			decoy_count -= 1
		# Cada retrato só pode ser sorteado uma vez dentro da mesma pasta.
		available_characters.shuffle()
		while cards.size() < decoy_count:
			var character: String = available_characters.pop_back()
			var gender: int = characters[character]["genero"]
			var full_name := _decoy_name(gender, folder_index, used_names)
			used_names[full_name] = true
			cards.append({"name": full_name, "character": character})
		cards.shuffle()
		if folder_index == target_folder:
			cards.insert(_next_correct_position(count), {"name": target_name, "character": target_character})
		folders.append(cards)
		selected_indices.append(0)


func _decoy_name(gender: int, folder_index: int, used_names: Dictionary) -> String:
	var catalog: Array = _names.nomes_masculinos if gender == CharacterManager.HOMEM else _names.nomes_femininos
	var first_names := catalog.filter(func(first: String): return folder_for_name(first) == folder_index)
	# Reutiliza o gerador existente, restringindo apenas a inicial  pasta.
	for attempt in 16:
		var generated: String = _names.gerar_nome(gender, 3)
		var tail := generated.substr(generated.find(" "))
		var candidate: String = first_names.pick_random() + tail
		if not used_names.has(candidate):
			return candidate
	# Catlogo finito: garante trmino mesmo com um sorteador repetitivo.
	for first in first_names:
		for surname in _names.sobrenomes:
			var candidate: String = first + " " + surname
			if not used_names.has(candidate):
				return candidate
	assert(false, "Catlogo de nomes insuficiente para preencher a pasta.")
	return ""


func current_card(folder_index: int) -> Dictionary:
	return folders[folder_index][selected_indices[folder_index]]


func move_card(folder_index: int, direction: int) -> void:
	selected_indices[folder_index] = wrapi(selected_indices[folder_index] + direction, 0, folders[folder_index].size())


func is_correct(folder_index: int, target_name: String, target_character: String) -> bool:
	var card := current_card(folder_index)
	return card["name"] == target_name and card["character"] == target_character
