extends Control

@onready var creditos_label: RichTextLabel = $CreditosLabel
var tempo := 0.0

func _ready():
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	creditos_label.bbcode_enabled = true
	creditos_label.text = "[wave amp=10 freq=3]
Ryan Faustino   @ryofac

Halyson Pimentel   @HalysonItallo

Ruan Macedo   @msruan
 


Antonio Meireles   @meidesu

Bianca Bezerra   @bianca-bezerra



Janielly Vieira   @janielly-vieira
[/wave]"

func _process(delta):
	tempo += delta
	creditos_label.set("custom_effects/wave/phase", tempo)
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameManager.change_to_menu_scene()
	if event.is_action_pressed("ui_end"):
		GameManager.transition_to_scene("res://scenes/secret_scene.tscn")
