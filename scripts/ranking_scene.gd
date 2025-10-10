extends Node2D

var vbox

@onready var sprite_ouro = $TrofeuOuro
@onready var sprite_prata = $TrofeuPrata
@onready var sprite_bronze = $TrofeuBronze

var fonte_ranking = preload("res://assets/fonts/Jersey25-Regular.ttf")

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		GameManager.change_to_menu_scene()
	if event.is_action_pressed("ui_page_down"):
		SaveManager.reset_save()

func _ready():
	await get_tree().process_frame
	
	if sprite_ouro:
		sprite_ouro.visible = false
		sprite_ouro.hide()
	if sprite_prata:
		sprite_prata.visible = false
		sprite_prata.hide()
	if sprite_bronze:
		sprite_bronze.visible = false
		sprite_bronze.hide()
	
	vbox = $CanvasLayer/ScrollContainer/VBoxContainer
	$Estrela1.play("brilhar")
	$Estrela2.play("brilhar")
	
	if not vbox:
		print("VBoxContainer não encontrado!")
		return
	
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var players = GameManager.get_dashboard()
	
	for child in vbox.get_children():
		child.queue_free()
	
	if not players or players.is_empty():
		var label = Label.new()
		label.text = "Ainda não temos vencedores!"
		label.add_theme_font_override("font", fonte_ranking)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 20)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(label)
		return
	
	players.sort_custom(func(a, b): return a["score"] > b["score"])
	
	for i in range(players.size()):
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		if i <= 2:
			var icon = TextureRect.new()
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(32, 32)
			
			match i:
				0:
					icon.texture = sprite_ouro.texture if sprite_ouro else null
				1:
					icon.texture = sprite_prata.texture if sprite_prata else null
				2:
					icon.texture = sprite_bronze.texture if sprite_bronze else null
			
			hbox.add_child(icon)
		else:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(32, 32)
			hbox.add_child(spacer)
		
		var label = Label.new()
		label.text = "%dº - %s (%.2f)" % [i + 1, players[i]["name"], players[i]["score"]]
		
		label.add_theme_font_override("font", fonte_ranking)
		
		if i == 0:
			label.add_theme_color_override("font_color", Color.GOLD)
			label.add_theme_font_size_override("font_size", 20)
			label.add_theme_color_override("font_outline_color", Color(0.8, 0.5, 0))
			label.add_theme_constant_override("outline_size", 3)
			
			animar_primeiro_lugar(label)
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_font_size_override("font_size", 18)
			label.add_theme_color_override("font_outline_color", Color.BLACK)
			label.add_theme_constant_override("outline_size", 2)
		
		hbox.add_child(label)
		vbox.add_child(hbox)
		

func animar_primeiro_lugar(label: Label):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(label, "scale", Vector2(0.95, 0.95), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
