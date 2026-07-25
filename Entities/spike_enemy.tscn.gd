extends CharacterBody2D

@export var charge_interval: float = 8.0
@export var charge_speed: float = 1240.0
@export var charge_overshoot_distance: float = 60.0
@export var recovery_duration: float = 1.0
@export var recovery_friction: float = 300.0
@export var wander_speed: float = 450.0
@export var spin_speed_degrees: float = 720.0

const DEATH_SOUNDS := [
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_a.wav"),
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_b.wav"),
]

var can_hit = true

enum State { IDLE, CHARGING, RECOVERING }
var state: State = State.IDLE

var player: Node2D
var charge_timer: float = 0.0
var charge_direction: Vector2 = Vector2.RIGHT
var overshoot_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	player = $"../Triangle"
	add_to_group("enemy")
	add_to_group("spiky_enemy")
	charge_timer = charge_interval


func _physics_process(delta: float) -> void:
	if not player:
		return

	match state:
		State.IDLE:
			_process_idle(delta)
		State.CHARGING:
			_process_charging(delta)
		State.RECOVERING:
			_process_recovering(delta)
	
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == player:
			if player.has_method("take_damage") and can_hit == true:
				player.take_damage(2)
				can_hit = false
				$HitCooldown.start()
	move_and_slide()

	if state == State.CHARGING:
		_check_player_hit()


func _process_idle(delta: float) -> void:
	charge_timer -= delta
	var to_player: Vector2 = (player.global_position - global_position).normalized()
	velocity = to_player * wander_speed
	rotation = to_player.angle()

	if charge_timer <= 0.0:
		_start_charge()


func _start_charge() -> void:
	state = State.CHARGING
	charge_direction = (player.global_position - global_position).normalized()
	overshoot_target = player.global_position + charge_direction * charge_overshoot_distance
	velocity = charge_direction * charge_speed
	$AudioStreamPlayer2D.play()


func _process_charging(delta: float) -> void:
	velocity = charge_direction * charge_speed
	rotation += deg_to_rad(spin_speed_degrees) * delta
	if global_position.distance_to(overshoot_target) <= 20.0:
		_start_recovery()


func _check_player_hit() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider == player:
			if player.has_method("take_damage"):
				player.take_damage(1)
				velocity = -(player.global_position - global_position).normalized() * 100
			$OvershootPeriod.start()
			return


func _start_recovery() -> void:
	state = State.RECOVERING
	charge_timer = recovery_duration


func _process_recovering(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, recovery_friction * delta)
	charge_timer -= delta
	if charge_timer <= 0.0:
		state = State.IDLE
		charge_timer = charge_interval


func die() -> void:
	Sfx.play(DEATH_SOUNDS.pick_random())
	$"../Triangle/Camera2D2".trigger_shake()
	$"../../TimeLeft".add_time(1)
	queue_free()


func _on_hit_cooldown_timeout() -> void:
	can_hit = true


func _on_overshoot_period_timeout() -> void:
	velocity = charge_direction * 0
	state = State.IDLE
