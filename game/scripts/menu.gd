## Hlavní menu – BOXY THE ADVENTURES: START / EXTRA
extends Node2D

const SKY := Color8(110, 192, 204)
const SEA := Color8(82, 158, 194)
const BG := preload("res://assets/menu_bg.png")
const SONG := preload("res://assets/music/menu.ogg")

var selected := 0
var cursor: AnimatedSprite2D
var music: AudioStreamPlayer
# pozice START a EXTRA v obrázku menu (208x208, zmenšeno na 180x180)
var items := [Vector2(62, 170), Vector2(-4, 200)]

func _ready() -> void:
	var scale_f := 180.0 / 208.0
	var ox := (320.0 - 180.0) / 2.0
	_rect(Rect2(0, 0, 320, 120), SKY)
	_rect(Rect2(0, 120, 320, 60), SEA)
	var bg := Sprite2D.new()
	bg.texture = BG
	bg.centered = false
	bg.scale = Vector2(scale_f, scale_f)
	bg.position = Vector2(ox, 0)
	add_child(bg)
	for i in items.size():
		items[i] = Vector2(ox + items[i].x * scale_f, items[i].y * scale_f)
	cursor = AnimatedSprite2D.new()
	cursor.sprite_frames = Sprites.frames("res://assets/sprites/boxy-classic.png")
	cursor.play("walk")
	cursor.scale = Vector2(0.75, 0.75)
	add_child(cursor)
	music = AudioStreamPlayer.new()
	var stream: AudioStreamOggVorbis = SONG
	stream.loop = true
	music.stream = stream
	add_child(music)
	music.play()
	_update_cursor()

func _rect(r: Rect2, c: Color) -> void:
	var cr := ColorRect.new()
	cr.position = r.position
	cr.size = r.size
	cr.color = c
	add_child(cr)

func _update_cursor() -> void:
	var p: Vector2 = items[selected]
	cursor.position = p

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("up") or event.is_action_pressed("down"):
		selected = 1 - selected
		_update_cursor()
	elif event.is_action_pressed("accept") or event.is_action_pressed("jump"):
		_choose()
	elif event is InputEventScreenTouch and event.pressed or event is InputEventMouseButton and event.pressed:
		var pos: Vector2 = get_global_mouse_position() if event is InputEventMouseButton else get_canvas_transform().affine_inverse() * event.position
		selected = 0 if pos.y < 160 else 1
		_update_cursor()
		_choose()

func _choose() -> void:
	if selected == 0:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		_show_extra()

func _show_extra() -> void:
	var l := Label.new()
	l.text = "EXTRA – už brzy..."
	l.position = Vector2(110, 85)
	add_child(l)
	await get_tree().create_timer(1.5).timeout
	l.queue_free()
