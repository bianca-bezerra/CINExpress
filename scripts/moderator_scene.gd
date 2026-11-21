extends CanvasLayer

# Referências aos nós da cena
@onready var search_line_edit = $Control/Panel/VBoxContainer/HboxContainer_Search/LineEdit
@onready var player_list: ItemList = $Control/Panel/VBoxContainer/VSplitContainer/VScrollBar/ItemList
@onready var selected_player_name = $Control/Panel/VBoxContainer/HBoxContainer_PlayerInfo/LabelPlayerSelected
@onready var remove_button = $Control/Panel/VBoxContainer/HBoxContainer_PlayerInfo/Actions/DeleteAction
@onready var edit_group = $Control/Panel/VBoxContainer/HBoxContainer_NewPlayerData
@onready var new_name_field = $Control/Panel/VBoxContainer/HBoxContainer_NewPlayerData/VBoxContainer/name
@onready var edit_button = $Control/Panel/VBoxContainer/HBoxContainer_PlayerInfo/Actions/EditAction
@onready var confirm_edit_button = $Control/Panel/VBoxContainer/HBoxContainer_NewPlayerData/VBoxContainer/Button

var selected_player_id = -1

func get_sorted_players():
	var _players = GameManager.get_dashboard().duplicate()
	_players.sort_custom(func(a, b): return a["score"] > b["score"])
	return _players

func _ready():
	SaveManager.load_game()
	
	# Conecta os sinais que configuramos na interface
	search_line_edit.text_changed.connect(_on_search_text_changed)
	player_list.item_selected.connect(_on_player_selected)
	remove_button.pressed.connect(_on_remove_pressed)
	edit_button.pressed.connect(_on_edit_pressed)
	confirm_edit_button.pressed.connect(_on_confirm_edit_pressed)

	# Popula a lista com todos os jogadores quando a cena inicia
	_update_player_list(get_sorted_players())
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.transition_to_scene("res://scenes/secret_scene.tscn")
	if Input.is_action_just_pressed("space"):
		player_list.add_item("aa")

# Esta função atualiza a lista de jogadores na tela
func _update_player_list(players_to_display: Array):
	player_list.clear() # Limpa a lista antes de adicionar novos itens
	selected_player_name.text = "Nenhum"
	selected_player_id = -1
	
	var _pos = 1
	for player in players_to_display:
		var _text = "%d - %s [%.1f]" % [_pos, player["name"], player["score"]]
		player_list.add_item(_text)
		# Guardamos o ID do jogador como "metadados" no item da lista.
		# Isso é crucial para saber quem é quem.
		var item_index = player_list.get_item_count() - 1
		player_list.set_item_metadata(item_index, player["id"])
		_pos+=1

# Chamado sempre que o texto na caixa de busca muda
func _on_search_text_changed(new_text: String):
	if new_text.is_empty():
		# Se a busca estiver vazia, mostra todos os jogadores
		_update_player_list(GameManager.get_dashboard())
		return

	# AQUI USAMOS A LÓGICA DE BUSCA (FILTRO)
	var search_text_lower = new_text.to_lower()
	var players_found = GameManager.get_dashboard().filter(func(player): return search_text_lower in player["name"].to_lower())
	
	_update_player_list(players_found)

# --- LÓGICA DE AÇÕES DE MODERAÇÃO ---

# Chamado quando um jogador é clicado na lista
func _on_player_selected(index: int):
	# Pegamos o ID que guardamos nos metadados
	selected_player_id = player_list.get_item_metadata(index)
	var player_data = PlayerManager.get_player_by_id(selected_player_id)
	if not player_data.is_empty():
		selected_player_name.text = player_data["name"]

func _on_remove_pressed():
	if selected_player_id != -1:
		PlayerManager.delete_player(selected_player_id)
	get_tree().reload_current_scene()

func _on_edit_pressed():
	if selected_player_id != -1:
		edit_group.visible = true
		var _player = PlayerManager.get_player_by_id(selected_player_id)
		new_name_field.text = _player["name"]

func _on_confirm_edit_pressed():
	if new_name_field.text != "":		
		PlayerManager.edit_player(selected_player_id, {"name": new_name_field.text})
	_update_player_list(get_sorted_players())
	edit_group.visible = false
		
