extends Sprite2D
class_name PersonSprite

func apply_walk_rotation():
	var time := Time.get_ticks_msec() / 1000.0
	var speed := 6.0  
	var amplitude := 0.15  
	rotation = sin(time * speed) * amplitude
