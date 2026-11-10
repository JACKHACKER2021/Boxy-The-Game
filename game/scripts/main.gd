## Hillwood Zone – první úroveň. Mapa je zapsaná jako text, ať se dá snadno upravit.
extends Node2D

const TILES := "res://assets/tiles/hillwood.png"
# indexy v hillwood.png
const T := {"L": 0, "K": 1, "|": 2, "s": 3, "g": 4, "#": 5, "d": 6, "~": 7, "w": 8}
const SOLID := "#d"

# . = vzduch, # = tráva, d = hlína, ~ = hladina, w = voda
# P = start hráče, M = Dr. Maniac
const LEVEL := [
	"..........................................................................................",
	"..........................................................................................",
	"..........................................................................................",
	"..........................................................................................",
	"..........................................................................................",
	"..............................###.................###.....................................",
	".............................................................................####.........",
	"....................####.......................M..................######..................",
	"..P...........M..............................#######......M...............................",
	"##########..##########....############.....##########..###########..###########.....######",
	"dddddddddd..dddddddddd....dddddddddddd.....dddddddddd..ddddddddddd..ddddddddddd.....dddddd",
	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
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
				p.name = "Player"
				add_child(p)
			elif c == "M":
				var e := Area2D.new()
				e.set_script(load("res://scripts/enemy.gd"))
				e.position = pos
				add_child(e)
				e.setup("res://assets/sprites/dr-maniac-classic.png")
	_build_touch_controls()

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
