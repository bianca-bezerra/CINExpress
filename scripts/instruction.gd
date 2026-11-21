extends Node2D


var _current_key
var _instruction_tween: Tween

func unbrazile(text: String) -> String:
	var s := text.strip_edges()
	s = s.to_lower()

	var subs := {
		"á":"a","à":"a","ã":"a","â":"a","ä":"a",
		"é":"e","è":"e","ê":"e","ë":"e",
		"í":"i","ì":"i","î":"i","ï":"i",
		"ó":"o","ò":"o","õ":"o","ô":"o","ö":"o",
		"ú":"u","ù":"u","û":"u","ü":"u",
		"ç":"c",
		"ñ":"n",
		"œ":"oe","æ":"ae"
	}
	
	for k in subs.keys():
		s = s.replace(k, subs[k])

	return s

func disable_not_activity_key():
	for child in get_children():
		if child.name == _current_key:
			continue
		child.visible = false

func setup_instruction(key: String, show_key_outside_first_level: bool = false):
	if _instruction_tween:
		_instruction_tween.kill()
	_current_key = unbrazile(key).to_pascal_case()
	
	disable_not_activity_key()
	var keyboard_sprite = find_child(_current_key)
	
	if GameManager.current_level == 0:
		var tween = create_tween()
		_instruction_tween = tween
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(keyboard_sprite, "scale", Vector2(1.2, 1.2), 0.30)
		tween.tween_property(keyboard_sprite, "scale", Vector2(1, 1), 0.30)
		
		keyboard_sprite.visible = true
	else:
		keyboard_sprite.visible = show_key_outside_first_level
		
func deactivate_instruction():
	if _instruction_tween:
		_instruction_tween.kill()
	if _current_key == null or _current_key.is_empty():
		return
	var keyboard_sprite = find_child(_current_key)
	keyboard_sprite.visible = false
