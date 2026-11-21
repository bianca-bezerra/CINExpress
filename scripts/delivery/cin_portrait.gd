extends RefCounted
## O recorte padro acompanha o topo visvel de sprites de alturas diferentes.

static func from_character(texture: Texture2D, region: Rect2 = Rect2()) -> AtlasTexture:
	var portrait := AtlasTexture.new()
	portrait.atlas = texture
	if region.has_area():
		portrait.region = region
	else:
		var bounds := texture.get_image().get_used_rect()
		portrait.region = Rect2(bounds.position.x, bounds.position.y, bounds.size.x, mini(25, bounds.size.y))
	portrait.filter_clip = true
	return portrait
