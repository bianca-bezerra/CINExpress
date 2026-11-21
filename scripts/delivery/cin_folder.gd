extends Node2D

const CardScene = preload("res://scenes/components/cin_card.tscn")
const TabFont = preload("res://assets/fonts/nokiafc22.ttf")
const TAB_FONT_SIZE := 8

@export var card_origin := Vector2(2, -30)
@export var card_spacing: float = 6.0
@export var card_lift: float = 18.0

var cards: Array[Node2D] = []
var _sprite_frames: SpriteFrames
var closed_bounds := Rect2()


func setup(group: String, entries: Array, characters: Dictionary) -> void:
	var sheet := load("res://assets/sprites/delivery/folders/%s.png" % group) as Texture2D
	closed_bounds = Rect2(sheet.get_image().get_region(Rect2i(0, 0, 87, 48)).get_used_rect())
	_sprite_frames = SpriteFrames.new()
	_sprite_frames.remove_animation("default")
	_sprite_frames.add_animation("closed")
	_sprite_frames.add_animation("open")
	_sprite_frames.add_frame("closed", _folder_frame(sheet, 0))
	_sprite_frames.add_frame("open", _folder_frame(sheet, 1))
	$FolderSprite.sprite_frames = _sprite_frames
	$FolderSprite.animation = "closed"
	_add_tab_label(sheet, group)
	for i in entries.size():
		var card := CardScene.instantiate()
		$Cards.add_child(card)
		card.lift = card_lift
		card.setup(entries[i], characters[entries[i]["character"]]["triste"], card_origin + Vector2(i * card_spacing, i * 2))
		cards.append(card)


func _add_tab_label(sheet: Texture2D, group: String) -> void:
	var image := sheet.get_image()
	for y in 48:
		for x in 87:
			if image.get_pixel(x, y).a > 0.5:
				var tab_right := x
				while tab_right + 1 < 87 and image.get_pixel(tab_right + 1, y).a > 0.5:
					tab_right += 1
				var text_width := TabFont.get_string_size(group, HORIZONTAL_ALIGNMENT_LEFT, -1, TAB_FONT_SIZE).x
				var tab_width := tab_right - x + 1
				var label := Label.new()
				label.name = "TabLabel"
				label.z_index = 1
				label.position = Vector2(roundf(x + (tab_width - text_width) / 2.0), y + 1)
				label.text = group
				label.add_theme_font_override("font", TabFont)
				label.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
				label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.16))
				label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
				$FolderSprite.add_child(label)
				return


func _folder_frame(sheet: Texture2D, frame_index: int) -> AtlasTexture:
	var frame_size := Vector2(sheet.get_width() / 2.0, sheet.get_height())
	var frame := AtlasTexture.new()
	frame.atlas = sheet
	frame.region = Rect2(Vector2(frame_size.x * frame_index, 0), frame_size)
	frame.filter_clip = true
	return frame


func show_selection(selected_index: int, active: bool, immediate: bool = false) -> void:
	$FolderSprite.animation = "open" if active else "closed"
	$FolderSprite.frame = 0
	if $FolderSprite.has_node("TabLabel"):
		$FolderSprite.get_node("TabLabel").visible = not active
	$Cards.visible = active
	for i in cards.size():
		cards[i].set_selected(active and i == selected_index, immediate)
