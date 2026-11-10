## Nepřítel, který chodí sem a tam (Dr. Maniac).
extends Area2D

var sprite: AnimatedSprite2D
var speed := 30.0
var start_x := 0.0
var range_px := 48.0

func setup(sprite_path: String) -> void:
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Sprites.frames(sprite_path)
	sprite.play("walk")
	add_child(sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 14)
	col.shape = shape
	add_child(col)
	start_x = position.x
	body_entered.connect(_on_body)

func _physics_process(delta: float) -> void:
	position.x += speed * delta
	if abs(position.x - start_x) > range_px:
		speed = -speed
	sprite.flip_h = speed < 0

func _on_body(body: Node) -> void:
	if body.has_method("die"):
		# skok na hlavu nepřítele ho porazí
		if body.velocity.y > 0 and body.position.y < position.y - 6:
			body.velocity.y = -250
			queue_free()
		else:
			body.die()
