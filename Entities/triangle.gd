extends CharacterBody2D
@export var speed = 750.0
@export var dash_speed = 1750
@export var friction = 500
@export var bounce_speed_retention = 0.6
@export var stun_duration = 0.5
var dashing = false
var direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var can_move = true
var can_dash = true
enum Mode { DASH, BOUNCE }
var mode: Mode = Mode.DASH
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var stun_timer: Timer = $stunt_timer

func _ready() -> void:
	stun_timer.one_shot = true
	if not stun_timer.timeout.is_connected(_on_stun_timer_timeout):
		stun_timer.timeout.connect(_on_stun_timer_timeout)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not dashing:
		look_at(get_global_mouse_position())

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		dash_direction = (get_global_mouse_position() - global_position).normalized()
		rotation = dash_direction.angle()
		$AudioStreamPlayer2D.play()
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
	if Input.is_action_just_pressed("toggle_mode"):
		_toggle_mode()
	if can_move:	
		if dashing:
			velocity = dash_speed * dash_direction
		else:
			if Input.is_action_pressed("propel"):
				var dir = (get_global_mouse_position() - global_position).normalized()
				velocity = speed * dir
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_handle_wall_collisions()

func _toggle_mode() -> void:
	if mode == Mode.DASH:
		mode = Mode.BOUNCE
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("bounce"):
			sprite.play("bounce")
	else:
		mode = Mode.DASH
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("dash"):
			sprite.play("dash")

func _handle_wall_collisions() -> void:
	if not dashing:
		return
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()

		if collider and collider.is_in_group("enemy") and mode == Mode.DASH:
			_kill_enemy(collider)
			continue

		if mode == Mode.BOUNCE:
			velocity = velocity.bounce(normal) * bounce_speed_retention
			dash_direction = velocity.normalized()
			rotation = dash_direction.angle()
		else:
			dashing = false
			velocity = Vector2.ZERO
			_apply_stun()
		break

func _kill_enemy(enemy: Node) -> void:
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()

func _apply_stun() -> void:
	can_move = false
	stun_timer.stop()
	stun_timer.start(stun_duration)

func _on_stun_timer_timeout() -> void:
	can_move = true

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	
func hazard_kill() -> void:
	# We'll have to add here a respawn or something
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	dashing = false
