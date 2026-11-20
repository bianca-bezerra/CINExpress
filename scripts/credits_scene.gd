extends Control

@onready var creditos_label: RichTextLabel = $CreditosLabel
var tempo := 0.0

func _ready():
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

	creditos_label.bbcode_enabled = true
	creditos_label.text = "\n\n".join([
		_categoria("#f0b429", "CONCEPÇÃO", [
			"Celeste Ribeiro   @celesteribi",
			"Natasha Meireles   @natashalmeireles",
		]),
		_categoria("#d83441", "DESENVOLVIMENTO", [
			"Antonio Meireles   @meidesu",
			"Bianca Bezerra   @bianca-bezerra",
			"Halyson Pimentel   @HalysonItallo",
			"Ruan Macedo   @msruan",
			"Ryan Faustino   @ryofac",
			"Xamã Cardoso   @Xamacardoso",
		]),
		_categoria("#009bba", "ARTE", [
			"Antonio Meireles   @meidesu",
			"Bianca Bezerra   @bianca-bezerra",
		]),
		_categoria("#23b773", "DESIGN", [
			"Janielly Vieira   @janielly-vieira",
		]),
	])


## Título colorido (parado) + nomes com o efeito de onda, um por linha
func _categoria(cor: String, titulo: String, nomes: Array) -> String:
	return "[font_size=11][color=%s]%s[/color][/font_size]\n[wave amp=10 freq=3]%s[/wave]" % [cor, titulo, "\n".join(nomes)]

func _process(delta):
	tempo += delta
	creditos_label.set("custom_effects/wave/phase", tempo)
	
func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameManager.change_to_menu_scene()
	if event.is_action_pressed("ui_end"):
		get_tree().change_scene_to_file("res://scenes/secret_scene.tscn")
