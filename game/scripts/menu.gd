## Hlavní menu – BOXY THE ADVENTURES, s animacemi: mraky, houpající se nadpis, blikající START
extends Node2D

const SKY := Color8(110, 192, 204)
const SEA := Color8(82, 158, 194)
const S := 0.75                  # zmenšení obrázku menu (208 px -> 156 px)
const OFS := Vector2(82, 12)     # kde leží obrázek menu na obrazovce 320x180

var selected := 0
var cursor: AnimatedSprite2D
var title: Sprite2D
var items: Array[Sprite2D] = []
var clouds: Array[Sprite2D] = []
var t := 0.0
var leaving := false

func p(x: float, y: float) -> Vector2:
	return OFS + Vector2(x, y) * S

func _sprite(path: String, pos: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(path)
	s.centered = false
	s.scale = Vector2(S, S)
	s.position = pos
	add_child(s)
	return s

func _ready() -> void:
	_rect(Rect2(0, 0, 320, 115), SKY)
	_rect(Rect2(0, 115, 320, 65), SEA)
	_sprite("res://assets/menu_bg_clean.png", OFS)
	# mraky plují přes celou obrazovku
	for i in 6:
		var c := _sprite("res://assets/menu_cloud.png", Vector2(i * 60 + randf() * 20, 18 + (i % 2) * 26))
		clouds.append(c)
	title = _sprite("res://assets/menu_title.png", p(14, 60))
	items.append(_sprite("res://assets/menu_start.png", p(62, 158)))
	items.append(_sprite("res://assets/menu_extra.png", p(0, 188)))
	cursor = AnimatedSprite2D.new()
	cursor.sprite_frames = Sprites.frames("res://assets/sprites/boxy-classic.png")
	cursor.play("walk")
	cursor.scale = Vector2(0.75, 0.75)
	add_child(cursor)
	if SaveGame.has_checkpoint():
		var l := Label.new()
		l.text = "pokračovat od checkpointu"
		l.add_theme_font_size_override("font_size", 8)
		l.position = p(62, 140)
		add_child(l)
	var music := AudioStreamPlayer.new()
	var stream: AudioStreamOggVorbis = load("res://assets/music/menu.ogg")
	stream.loop = true
	music.stream = stream
	add_child(music)
	music.play()
	# nadpis přiletí shora
	var target := title.position
	title.position.y = -60
	create_tween().tween_property(title, "position:y", target.y, 0.9).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_fade(1.0, 0.0, 0.6)

func _rect(r: Rect2, c: Color) -> void:
	var cr := ColorRect.new()
	cr.position = r.position
	cr.size = r.size
	cr.color = c
	add_child(cr)

func _fade(from: float, to: float, time: float) -> Tween:
	var layer := CanvasLayer.new()
	add_child(layer)
	var black := ColorRect.new()
	black.size = Vector2(320, 180)
	black.color = Color(0, 0, 0, from)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(black)
	var tw := create_tween()
	tw.tween_property(black, "color:a", to, time)
	return tw

func _process(delta: float) -> void:
	t += delta
	for c in clouds:
		c.position.x -= 6 * delta
		if c.position.x < -30:
			c.position.x = 330
	if not leaving:
		title.offset.y = sin(t * 2.0) * 2.0
	# vybraná položka bliká, druhá svítí
	var speed := 12.0 if leaving else 3.0
	for i in items.size():
		items[i].visible = i != selected or fmod(t * speed, 2.0) < 1.4
	var it := items[selected]
	cursor.position = it.position + Vector2(-8, 9 + sin(t * 6) * 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if leaving:
		return
	if event.is_action_pressed("up") or event.is_action_pressed("down"):
		selected = 1 - selected
	elif event.is_action_pressed("accept") or event.is_action_pressed("jump"):
		_choose()
	elif (event is InputEventScreenTouch or event is InputEventMouseButton) and event.pressed:
		var pos: Vector2 = get_canvas_transform().affine_inverse() * event.position
		selected = 0 if pos.y < p(0, 186).y else 1
		_choose()

func _choose() -> void:
	if selected == 0:
		leaving = true
		await get_tree().create_timer(0.6).timeout
		await _fade(0.0, 1.0, 0.4).finished
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		var l := Label.new()
		l.text = "EXTRA – už brzy..."
		l.position = Vector2(115, 80)
		add_child(l)
		await get_tree().create_timer(1.5).timeout
		l.queue_free()
