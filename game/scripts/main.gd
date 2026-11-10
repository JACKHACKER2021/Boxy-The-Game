## Hillwood Zone – první úroveň. Mapa je zapsaná jako text, ať se dá snadno upravit.
extends Node2D

const TILES := "res://assets/tiles/hillwood.png"
# indexy v hillwood.png
const T := {"L": 0, "K": 1, "|": 2, "s": 3, "g": 4, "#": 5, "d": 6, "~": 7, "w": 8}
const SOLID := "#d"

# . = vzduch, # = tráva, d = hlína, ~ = hladina, w = voda
# P = start hráče, M = Dr. Maniac
const LEVEL := [
	"................................................................................................................................................",
	"................................................................................................................................................",
	"................................................................................................................................................",
	"................................................................................................................................................",
	"................................................................................................................................................",
	".................................................C..............................##...##...##....................................................",
	".................................................###..............................................####..........................................",
	"..............................................###ddd.....................................................###....................................",
	"..P............................^.....^^....###dddddd..................M.C.....^^^^^^^^^^^^^^^^.....M......C......=.......=................F.....",
	"##############...##########################ddddddddd.....=........############################################....................##############",
	"dddddddddddddd...ddddddddddddddddddddddddddddddddddd..............dddddddddddddddddddddddddddddddddddddddddddd....................dddddddddddddd",
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
]

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color8(41, 178, 77))
	_build_background()
	var walls := StaticBody2D.new()
	add_child(walls)
	for y in LEVEL.size():
		var row: String = LEVEL[y]
		for x in row.length():
			var c := row[x]
			var pos := Vector2(x * 16 + 8, y * 16 + 8 + 4)
			if T.has(c):
				var s := Sprite2D.new()
				s.texture = Sprites.tile(TILES, T[c])
				s.position = pos
				add_child(s)
			if c == "~":
				_add_tile(pos + Vector2(0, 16), "w")
			if c in SOLID:
				var col := CollisionShape2D.new()
				var r := RectangleShape2D.new()
				r.size = Vector2(16, 16)
				col.shape = r
				col.position = pos
				walls.add_child(col)
			elif c == "P":
				var p := CharacterBody2D.new()
				p.set_script(load("res://scripts/player.gd"))
				p.position = pos
				var saved = SaveGame.load_checkpoint("hillwood1")
				if saved != null:
					p.position = saved
				p.name = "Player"
				p.z_index = 10
				add_child(p)
			elif c == "M":
				var e := Area2D.new()
				e.set_script(load("res://scripts/enemy.gd"))
				e.position = pos
				add_child(e)
				e.setup("res://assets/sprites/dr-maniac-classic.png")
				e.z_index = 5
			elif c == "^":
				_add_spikes(pos)
			elif c == "=":
				_add_moving_platform(pos)
			elif c == "C":
				_add_checkpoint(pos)
			elif c == "F":
				_add_finish(pos)
	_build_touch_controls()

func _pixel_texture(rows: Array, colors: Dictionary) -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in rows.size():
		for x in rows[y].length():
			var ch: String = rows[y][x]
			if colors.has(ch):
				img.set_pixel(x, y, colors[ch])
	return ImageTexture.create_from_image(img)

func _add_spikes(pos: Vector2) -> void:
	# ostny – dotek = návrat na start
	var spr := Sprite2D.new()
	spr.texture = _pixel_texture([
		"", "", "", "", "", "", "",
		"...w.......w....",
		"...g.......g....",
		"..wgg.....wgg...",
		"..wgg.....wgg...",
		".wwggg...wwggg..",
		".wwggg...wwggg..",
		"wwwgggg.wwwgggg.",
		"wwwgggg.wwwgggg.",
		"kkkkkkkkkkkkkkkk",
	], {"w": Color8(230, 230, 230), "g": Color8(140, 140, 150), "k": Color8(40, 40, 50)})
	spr.position = pos
	spr.z_index = 4
	add_child(spr)
	var hit := Area2D.new()
	var col := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(12, 7)
	col.shape = r
	col.position = Vector2(0, 4)
	hit.add_child(col)
	hit.position = pos
	hit.body_entered.connect(func(b): if b.has_method("die"): b.die())
	add_child(hit)

func _add_moving_platform(pos: Vector2) -> void:
	# plošina ze 3 dlaždic trávy, jezdí doprava a zpět
	var body := AnimatableBody2D.new()
	body.position = pos
	body.z_index = 3
	for i in 3:
		var spr := Sprite2D.new()
		spr.texture = Sprites.tile(TILES, T["#"])
		spr.position = Vector2(i * 16, 0)
		body.add_child(spr)
	var col := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(48, 16)
	col.shape = r
	col.position = Vector2(16, 0)
	col.one_way_collision = true
	body.add_child(col)
	add_child(body)
	var tw := create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(body, "position:x", pos.x + 80, 2.0).set_trans(Tween.TRANS_SINE)
	tw.tween_property(body, "position:x", pos.x, 2.0).set_trans(Tween.TRANS_SINE)

func _add_checkpoint(pos: Vector2) -> void:
	# checkpoint: šedý sloupek, po dotyku se kulička rozsvítí a hra se uloží
	var post := Sprite2D.new()
	var rows := [
		"......oooo......",
		".....oooooo.....",
		".....oooooo.....",
		"......oooo......",
		".......kk.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		".......gg.......",
		"......kggk......",
		".....kkkkkk.....",
		".....kkkkkk.....",
	]
	var off := _pixel_texture(rows, {"o": Color8(90, 90, 110), "k": Color8(40, 40, 50), "g": Color8(170, 170, 180)})
	var on := _pixel_texture(rows, {"o": Color8(246, 146, 30), "k": Color8(40, 40, 50), "g": Color8(170, 170, 180)})
	post.texture = off
	post.position = pos
	post.z_index = 2
	add_child(post)
	var hit := Area2D.new()
	var col := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(12, 16)
	col.shape = r
	hit.add_child(col)
	hit.position = pos
	add_child(hit)
	hit.body_entered.connect(func(b):
		if not b.has_method("die") or post.texture == on:
			return
		post.texture = on
		b.spawn = pos
		SaveGame.save_checkpoint("hillwood1", pos)
		var l := Label.new()
		l.text = "ULOŽENO!"
		l.add_theme_font_size_override("font_size", 8)
		l.position = pos + Vector2(-18, -28)
		l.z_index = 20
		add_child(l)
		var tw := create_tween()
		tw.tween_property(l, "position:y", l.position.y - 12, 1.0)
		tw.parallel().tween_property(l, "modulate:a", 0.0, 1.0)
		tw.tween_callback(l.queue_free))

func _add_finish(pos: Vector2) -> void:
	# cílová vlajka
	var spr := Sprite2D.new()
	spr.texture = _pixel_texture([
		"..kooooooo......",
		"..kooyyoooo.....",
		"..koyooyooooo...",
		"..koooyoooooooo.",
		"..kooyoyooooo...",
		"..kooooooooo....",
		"..koooooo.......",
		"..k.............",
		"..k.............",
		"..k.............",
		"..k.............",
		"..k.............",
		"..k.............",
		"..k.............",
		".kkk............",
		"kkkkk...........",
	], {"k": Color8(60, 40, 30), "o": Color8(246, 146, 30), "y": Color8(255, 240, 80)})
	spr.position = pos
	add_child(spr)
	var hit := Area2D.new()
	var col := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(16, 32)
	col.shape = r
	hit.add_child(col)
	hit.position = pos
	hit.body_entered.connect(_on_finish)
	add_child(hit)

func _on_finish(body: Node) -> void:
	if not body.has_method("die"):
		return
	SaveGame.clear()
	body.set_physics_process(false)
	var ui := CanvasLayer.new()
	add_child(ui)
	var l := Label.new()
	l.text = "HILLWOOD ACT 1 – HOTOVO!"
	l.position = Vector2(70, 70)
	ui.add_child(l)
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _add_tile(pos: Vector2, key: String) -> void:
	var s := Sprite2D.new()
	s.texture = Sprites.tile(TILES, T[key])
	s.position = pos
	add_child(s)

func _build_background() -> void:
	# jako na mapě Hillwood Zone: 2 řady listí, kmeny přes oblohu, pod nimi zelená tráva
	var width: int = LEVEL[0].length()
	for x in width:
		var px := x * 16 + 8
		_add_tile(Vector2(px, -4), "L")
		_add_tile(Vector2(px, 12), "L")
		_add_tile(Vector2(px, 28), "K" if x % 2 == 0 else "s")
		_add_tile(Vector2(px, 44), "|" if x % 2 == 0 else "g")
		for y in range(3, 11):
			_add_tile(Vector2(px, y * 16 + 12), "g")

func _build_touch_controls() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	_touch_button(ui, "◀", "left", Vector2(6, 140))
	_touch_button(ui, "▶", "right", Vector2(46, 140))
	_touch_button(ui, "▲", "jump", Vector2(280, 140))

func _touch_button(ui: CanvasLayer, label: String, action: String, pos: Vector2) -> void:
	var b := TouchScreenButton.new()
	var img := Image.create(34, 34, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.25))
	b.texture_normal = ImageTexture.create_from_image(img)
	b.action = action
	b.position = pos
	b.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
	var l := Label.new()
	l.text = label
	l.position = Vector2(10, 6)
	b.add_child(l)
	ui.add_child(b)
