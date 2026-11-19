extends Node2D

@onready var input = $NameInput
@onready var warning_label: RichTextLabel = $WarningLabel
@onready var profile_search: LineEdit = $ProfileSearch
@onready var profile_list: ItemList = $ProfileList
@onready var no_profiles_label: Label = $NoProfilesLabel
@onready var use_profile_button: Button = $UseProfileButton

var _visible_profile_ids: Array[int] = []


func _ready() -> void:
	warning_label.visible = false
	input.text_changed.connect(_on_name_input_text_changed)
	profile_search.text_changed.connect(_on_profile_search_text_changed)
	profile_list.item_selected.connect(_on_profile_selected)
	profile_list.item_activated.connect(_on_profile_activated)
	use_profile_button.pressed.connect(_on_use_profile_button_pressed)
	_refresh_profile_list("")
	input.grab_focus()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameManager.change_to_menu_scene()

func _on_name_input_text_submitted(new_text: String) -> void:
	var player_name := new_text.strip_edges()
	var min_length := 3
	var max_length := 20
	var allowed_pattern := RegEx.new()
	allowed_pattern.compile("^[A-Za-zÀ-ÿ0-9_ ]+$")  
	

	if player_name == "":
		_show_warning("Insira um nome válido")
		return
	
	
	if player_name.length() < min_length:
		_show_warning("O nome deve ter pelo menos %d caracteres" % min_length)
		return
	
	if player_name.length() > max_length:
		_show_warning("O nome pode ter no máximo %d caracteres" % max_length)
		return
	
	
	if not allowed_pattern.search(player_name):
		_show_warning("Use apenas letras, números e espaços")
		return
	
	
	for dashboard in SaveManager.game_data.get("dashboard", []):
		var old_player_name := str(dashboard.get("name", "")).strip_edges()
		if player_name.to_lower() == old_player_name.to_lower():
			_show_warning("Esse nome já existe. Selecione o perfil salvo abaixo.")
			return 
	
	_hide_warning()

	PlayerManager.register_new_player(player_name)
	GameManager.start_game()


func _on_name_input_text_changed(_new_text: String) -> void:
	_hide_warning()


func _on_profile_search_text_changed(query: String) -> void:
	_hide_warning()
	_refresh_profile_list(query)


func _refresh_profile_list(query: String) -> void:
	profile_list.clear()
	_visible_profile_ids.clear()
	use_profile_button.disabled = true

	var saved_profiles: Array[Dictionary] = []
	for profile in SaveManager.game_data.get("dashboard", []):
		if profile is Dictionary and not str(profile.get("name", "")).strip_edges().is_empty():
			saved_profiles.append(profile)

	if saved_profiles.is_empty():
		profile_search.visible = false
		profile_list.visible = false
		no_profiles_label.visible = false
		use_profile_button.visible = false
		return

	profile_search.visible = true
	profile_list.visible = true
	use_profile_button.visible = true
	var normalized_query := query.strip_edges().to_lower()
	saved_profiles.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("name", "")).nocasecmp_to(str(b.get("name", ""))) < 0
	)

	for profile in saved_profiles:
		var profile_name := str(profile.get("name", "")).strip_edges()
		if not normalized_query.is_empty() and not profile_name.to_lower().contains(normalized_query):
			continue
		var profile_id := int(profile.get("id", -1))
		if profile_id < 0:
			continue
		var best_score := int(round(float(profile.get("score", 0.0))))
		profile_list.add_item("%s  -  %d pts" % [profile_name, best_score])
		_visible_profile_ids.append(profile_id)

	no_profiles_label.visible = _visible_profile_ids.is_empty()
	if no_profiles_label.visible:
		no_profiles_label.text = "Nenhum perfil encontrado"


func _show_warning(msg: String) -> void:
	warning_label.visible = true
	warning_label.text = msg
	input.grab_click_focus()
	

func _hide_warning() -> void:
	warning_label.visible = false


func _on_profile_selected(index: int) -> void:
	use_profile_button.disabled = index < 0 or index >= _visible_profile_ids.size()


func _on_profile_activated(index: int) -> void:
	_on_profile_selected(index)
	_on_use_profile_button_pressed()


func _on_use_profile_button_pressed() -> void:
	var selected_index := profile_list.get_selected_items()
	if selected_index.is_empty():
		return
	var item_index := selected_index[0]
	if item_index < 0 or item_index >= _visible_profile_ids.size():
		return
	if not PlayerManager.register_existing_player(_visible_profile_ids[item_index]):
		_show_warning("Não foi possível carregar esse perfil. Atualize a lista e tente de novo.")
		return
	_hide_warning()
	GameManager.start_game()


func _on_previous_button_pressed():
	GameManager.change_to_menu_scene()
