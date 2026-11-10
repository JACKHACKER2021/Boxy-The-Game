## Hráč – rychlý běh a skok ve stylu retro plošinovek.
extends CharacterBody2D

const ACCEL := 500.0
const FRICTION := 600.0
const MAX_SPEED := 220.0
const JUMP := -330.0
const GRAVITY := 800.0

var sprite: AnimatedSprite2D
var spawn: Vector2

func _ready() -> void:
	spawn = position
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = Sprites.frames("res://assets/sprites/boxy-classic.png")
	sprite.play("stand")
	add_child(sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 15)
	col.shape = shape
	col.position.y = 0.5
	add_child(col)
	var cam := Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.limit_top = 0
	cam.limit_bottom = 180
	cam.limit_left = 0
	add_child(cam)

func _physics_process(delta: float) -> void:
	var dir := Input.get_axis("left", "right")
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * MAX_SPEED, ACCEL * delta)
		sprite.flip_h = dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
	move_and_slide()
	sprite.play("walk" if abs(velocity.x) > 10 else "stand")
	sprite.speed_scale = 1.0 + abs(velocity.x) / 80.0
	if position.y > 220:
		die()

func die() -> void:
	position = spawn
	velocity = Vector2.ZERO
