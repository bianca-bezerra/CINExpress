extends Node2D

@onready var input = $NameInput
@onready var warning_label: RichTextLabel = $WarningLabel


func _ready() -> void:
	warning_label.visible = false
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
			_show_warning("Esse nome ja existe")
			return 
	
	_hide_warning()
	print("bora")
	PlayerManager.register_new_player(player_name)
	GameManager.start_game()


func _show_warning(msg: String) -> void:
	warning_label.visible = true
	warning_label.text = msg
	input.grab_click_focus()
	

func _hide_warning() -> void:
	warning_label.visible = false


func _on_previous_button_pressed():
	GameManager.change_to_menu_scene()
