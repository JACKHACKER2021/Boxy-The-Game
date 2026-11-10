## Pomocné funkce pro sprity 16x16 (4 snímky: stání 1, stání 2, chůze 1, chůze 2).
class_name Sprites

static func frames(path: String) -> SpriteFrames:
	var tex: Texture2D = load(path)
	var sf := SpriteFrames.new()
	sf.add_animation("stand")
	sf.add_animation("walk")
	sf.set_animation_speed("stand", 2)
	sf.set_animation_speed("walk", 8)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * 16, 0, 16, 16)
		sf.add_frame("stand" if i < 2 else "walk", at)
	sf.remove_animation("default")
	return sf

static func tile(path: String, index: int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = load(path)
	at.region = Rect2(index * 16, 0, 16, 16)
	return at
