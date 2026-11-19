extends CanvasLayer

@onready var game_timer_slider: HSlider = $GameTimerSlider
@onready var game_timer_value: Label = $Panel/GameTimerValue
@onready var show_assistant_checkbox: CheckBox = $Panel/CheckBox
@onready var ok_button: Button = $Panel/OkButton
@onready var moderation_button: Button = $Panel/ModerationButton

# Variáveis para armazenar as configurações
var game_time: int = 10
var show_assistant: bool = false

func _ready() -> void:
	# Define valores iniciais
	game_timer_slider.value = GameManager.total_game_duration
	game_timer_value.text = str(game_timer_slider.value)
	show_assistant_checkbox.button_pressed = GameManager.can_show_assistent

	# Conecta sinais
	game_timer_slider.value_changed.connect(_on_game_timer_changed)
	ok_button.pressed.connect(_on_ok_pressed)
	
	moderation_button.pressed.connect(_on_moderation_pressed)
	
func _on_game_timer_changed(value: float) -> void:
	GameManager.total_game_duration = int(value)
	game_timer_value.text = str(GameManager.total_game_duration)
	

func _on_moderation_pressed() -> void:
	GameManager.transition_to_scene("res://scenes/moderator_scene.tscn")

func _on_ok_pressed() -> void:
	GameManager.can_show_assistent = show_assistant_checkbox.button_pressed
	print("Configurações salvas:")
	print("→ Tempo de jogo:", game_time)
	print("→ Mostrar assistente:", show_assistant)
	GameManager.transition_to_scene("res://scenes/levels/menu_scene.tscn")
