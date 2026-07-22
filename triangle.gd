extends CharacterBody2D

const WINDOW_WIDTH: float = 1152.0
const WINDOW_HEIGHT: float = 648.0

const COLOR_BOUNCE_IDLE: Color = Color(1, 1, 1)
const COLOR_BOUNCE_ACTIVE: Color = Color(0.3, 0.9, 1)
const COLOR_DASH_MODE: Color = Color(1, 0.15, 0.15)
const COLOR_STUNNED: Color = Color(1, 0.6, 0.1)

@export var dash_max_distance: float = 500.0
@export var dash_min_distance: float = 40.0
@export var dash_speed: float = 1900.0
@export var dash_arrival_threshold: float = 14.0

@export var bounce_force: float = 280.0
@export var bounce_speed_retention: float = 0.3
@export var bounce_max_speed: float = 750.0

@export var idle_friction: float = 2500.0
@export var stun_duration: float = 0.3
@export var point_cone_degrees: float = 40.0

enum State { IDLE, ACTIVE, STUNNED }
enum Mode { DASH, BOUNCE }

var state: State = State.IDLE
var mode: Mode = Mode.BOUNCE

var move_timer: float = 0.0
var cooldown_timer: float = 0.0
var stun_timer: float = 0.0
var move_direction: Vector2 = Vector2.RIGHT
var aim_direction: Vector2 = Vector2.RIGHT
var dash_target_position: Vector2 = Vector2.ZERO

signal moved(direction: Vector2, used_mode: Mode)
signal bounced(new_direction: Vector2)
signal stunned()
signal enemy_killed(enemy: Node)
signal cooldown_ready()
signal mode_changed(new_mode: Mode)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_toggle_mode()
			return
		if event.button_index == MOUSE_BUTTON_LEFT \
		and state == State.IDLE \
		and cooldown_timer <= 0.0:
			_start_move()


func _toggle_mode() -> void:
	if mode == Mode.BOUNCE:
		mode = Mode.DASH
	else:
		mode = Mode.BOUNCE
	if state == State.IDLE:
		_apply_idle_color()
	mode_changed.emit(mode)


func _apply_idle_color() -> void:
	modulate = COLOR_DASH_MODE if mode == Mode.DASH else COLOR_BOUNCE_IDLE


func _physics_process(delta: float) -> void:
	_update_aim()
	_update_timers(delta)

	match state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, idle_friction * delta)
		State.ACTIVE:
			_process_active(delta)
		State.STUNNED:
			velocity = Vector2.ZERO

	move_and_slide()
	_handle_collisions()
	_check_window_bounds()


func _update_aim() -> void:
	if state == State.STUNNED:
		return
	aim_direction = (get_global_mouse_position() - global_position).normalized()
	if state == State.IDLE:
		rotation = aim_direction.angle()


func _update_timers(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer = max(cooldown_timer - delta, 0.0)
		if cooldown_timer == 0.0:
			cooldown_ready.emit()

	if state == State.STUNNED:
		stun_timer -= delta
		if stun_timer <= 0.0:
			_set_state(State.IDLE)


func _set_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE:
			_apply_idle_color()
			scale = Vector2.ONE
		State.ACTIVE:
			modulate = COLOR_DASH_MODE if mode == Mode.DASH else COLOR_BOUNCE_ACTIVE
			scale = Vector2(1.15, 0.85)
		State.STUNNED:
			modulate = COLOR_STUNNED
			scale = Vector2(0.85, 0.85)


func _start_move() -> void:
	move_direction = aim_direction
	rotation = move_direction.angle()
	_set_state(State.ACTIVE)

	if mode == Mode.DASH:
		var raw_distance: float = global_position.distance_to(get_global_mouse_position())
		var clamped_distance: float = clampf(raw_distance, dash_min_distance, dash_max_distance)
		dash_target_position = global_position + move_direction * clamped_distance
		velocity = move_direction * dash_speed
	else:
		velocity = move_direction * bounce_force

	moved.emit(move_direction, mode)


func _process_active(delta: float) -> void:
	if mode == Mode.DASH:
		if global_position.distance_to(dash_target_position) <= dash_arrival_threshold:
			_finish_move()
	else:
		move_timer -= delta


func _finish_move() -> void:
	_set_state(State.IDLE)
	cooldown_timer = 0.0
	velocity = Vector2.ZERO


func _handle_collisions() -> void:
	if state != State.ACTIVE:
		return

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()

		var hit_angle_deg: float = rad_to_deg(move_direction.angle_to(-normal))
		var is_point_hit: bool = absf(hit_angle_deg) <= (point_cone_degrees * 0.5)

		if collider and collider.is_in_group("enemy"):
			if is_point_hit:
				_kill_enemy(collider)
			else:
				_bounce_off(normal)
		elif collider and collider.is_in_group("spiky_enemy"):
			_bounce_off(normal)
		else:
			_hit_wall(normal)
		break


func _hit_wall(normal: Vector2) -> void:
	if mode == Mode.DASH:
		_stun()
	else:
		_bounce_off(normal)


func _check_window_bounds() -> void:
	if global_position.x <= 0.0:
		global_position.x = 0.0
		_hit_wall(Vector2.RIGHT)
	elif global_position.x >= WINDOW_WIDTH:
		global_position.x = WINDOW_WIDTH
		_hit_wall(Vector2.LEFT)

	if global_position.y <= 0.0:
		global_position.y = 0.0
		_hit_wall(Vector2.DOWN)
	elif global_position.y >= WINDOW_HEIGHT:
		global_position.y = WINDOW_HEIGHT
		_hit_wall(Vector2.UP)


func _kill_enemy(enemy: Node) -> void:
	enemy_killed.emit(enemy)
	if enemy.has_method("die"):
		enemy.die()
	elif enemy is Node:
		enemy.queue_free()


func _bounce_off(normal: Vector2) -> void:
	if state != State.ACTIVE:
		return

	velocity = velocity.bounce(normal) * bounce_speed_retention
	velocity = velocity.limit_length(bounce_max_speed)
	move_direction = velocity.normalized()
	rotation = move_direction.angle()

	bounced.emit(move_direction)


func _stun() -> void:
	global_position -= velocity.normalized() * 2.0
	_set_state(State.STUNNED)
	stun_timer = stun_duration
	velocity = Vector2.ZERO
	cooldown_timer = 0.0
	stunned.emit()


func get_cooldown_ratio() -> float:
	return 0.0 if state == State.IDLE else 1.0
