extends CharacterBody2D

const SPEED: float = 70.0
const PREFERRED_DISTANCE_MIN: float = 180.0
const PREFERRED_DISTANCE_MAX: float = 260.0
const DEADZONE: float = 30.0

const BURST_MISSILE_COUNT: int = 2
const BURST_INTERVAL: float = 0.2
const BURST_COOLDOWN: float = 4.5

@export var missile_scene: PackedScene

var player: Node2D
var burst_cooldown_timer: float = 0.0
var burst_shots_remaining: int = 0
var burst_timer: float = 0.0


func _ready() -> void:
	player = $"../Triangle"
	add_to_group("enemy")


func _physics_process(delta: float) -> void:
	if not player:
		return

	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()
	var direction: Vector2 = to_player.normalized()

	if distance < PREFERRED_DISTANCE_MIN - DEADZONE:
		velocity = -direction * SPEED
	elif distance > PREFERRED_DISTANCE_MAX + DEADZONE:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	rotation = direction.angle()

	_process_shooting(delta, distance)


func _process_shooting(delta: float, distance: float) -> void:
	burst_cooldown_timer -= delta

	if burst_shots_remaining > 0:
		burst_timer -= delta
		if burst_timer <= 0.0:
			_fire_missile()
			burst_shots_remaining -= 1
			burst_timer = BURST_INTERVAL
	elif burst_cooldown_timer <= 0.0 and distance <= PREFERRED_DISTANCE_MAX:
		burst_shots_remaining = BURST_MISSILE_COUNT
		burst_timer = 0.0
		burst_cooldown_timer = BURST_COOLDOWN


func _fire_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	if missile.has_method("set_target"):
		missile.set_target(player)


func die() -> void:
	queue_free()
