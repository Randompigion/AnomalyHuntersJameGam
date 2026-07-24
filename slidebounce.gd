extends CharacterBody2D

@export var speed = 750.0
@export var dash_speed = 1750
@export var friction = 500
@export var bounce_speed_retention = 0.6
@export var stun_duration = 0.5
@export var max_hp: int = 3

var hp: int = max_hp
var is_invincible: bool = false

var dashing = false
var direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var can_move = true
var can_dash = true
enum Mode { DASH, BOUNCE }
var mode: Mode = Mode.DASH

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var stun_timer: Timer = $stunt_timer
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound

func _ready() -> void:
	hp = max_hp
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
		if $AudioStreamPlayer2D.playing == false: # Optional: prevents overlapping sounds
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
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()

		if collider and collider.is_in_group("enemy"):
			if dashing and mode == Mode.DASH:
				_kill_enemy(collider)
			elif not dashing:
				take_damage(1)
			continue
		
		if dashing:
			if mode == Mode.BOUNCE:
				velocity = velocity.bounce(normal) * bounce_speed_retention
				dash_direction = velocity.normalized()
				rotation = dash_direction.angle()
				_play_bounce()
			else:
				dashing = false
				velocity = Vector2.ZERO
				_apply_stun()
			break
			
func _play_bounce() -> void:
	if bounce_sound.stream:
		bounce_sound.play()

func _kill_enemy(enemy: Node) -> void:
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()

func take_damage(amount: int) -> void:
	if is_invincible:
		return
		
	dashing = false
	velocity = Vector2.ZERO
	_apply_stun()
	
	is_invincible = true
	sprite.modulate.a = 0.5
	await get_tree().create_timer(1.0).timeout
	sprite.modulate.a = 1.0
	is_invincible = false

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
