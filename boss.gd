extends CharacterBody2D

@export var max_hp: int = 5
var hp: int

@export var attack_cooldown: float = 2.0
@export var weak_point_angle_width_degrees: float = 60.0
@export var weak_point_rotation_speed_degrees: float = 25.0
@export var weak_point_active_duration: float = 2.0
@export var weak_point_inactive_duration: float = 1.5

@export var missile_scene: PackedScene
@export var missile_burst_count: int = 5
@export var missile_burst_interval: float = 0.15

@export var random_missile_count: int = 8
@export var random_missile_interval: float = 0.2
@export var random_missile_loop: bool = true
@export var random_missile_color: Color = Color(0.2, 1.0, 0.8)

@export var ring_missile_count: int = 16
@export var ring_gap_degrees: float = 50.0
@export var ring_chance: float = 1.0 / 7.0

@export var laser_telegraph_duration: float = 2.0
@export var laser_active_duration: float = 0.6
@export var laser_length: float = 2000.0
@export var laser_count: int = 6
@export var laser_spread_degrees: float = 60.0
@export var laser_width: float = 18.0

@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_spawn_count: int = 3
@export var enemy_spawn_radius: float = 200.0

enum AttackType { HOMING_MISSILES, LASER, SPAWN }
enum State { IDLE, ATTACKING }
var state: State = State.IDLE

var player: Node2D
var weak_point_angle: float = 0.0
var attack_timer: float = 0.0
var weak_point_active: bool = true
var weak_point_timer: float = 0.0
var random_missile_loop_active: bool = false

@onready var laser_preview: Line2D = $LaserPreview
@onready var laser_beam: Line2D = $LaserBeam
@onready var weak_point_marker: Node2D = $WeakPointMarker


func _ready() -> void:
	hp = max_hp
	add_to_group("boss")
	attack_timer = attack_cooldown
	laser_preview.visible = false
	laser_beam.visible = false
	laser_preview.width = laser_width * 0.5
	laser_beam.width = laser_width
	weak_point_timer = weak_point_active_duration
	_update_weak_point_shader()
	if random_missile_loop:
		_start_random_missile_loop()


func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_tree().root.find_child("Triangle", true, false)
		if not player:
			return

	weak_point_angle = wrapf(
		weak_point_angle + deg_to_rad(weak_point_rotation_speed_degrees) * delta,
		0.0, TAU
	)
	weak_point_marker.position = Vector2(80, 0).rotated(weak_point_angle)

	weak_point_timer -= delta
	if weak_point_timer <= 0.0:
		if weak_point_active:
			weak_point_active = false
			weak_point_angle = randf() * TAU
			weak_point_timer = weak_point_inactive_duration
		else:
			weak_point_active = true
			weak_point_timer = weak_point_active_duration
		_update_weak_point_shader()

	if state == State.IDLE:
		attack_timer -= delta
		if attack_timer <= 0.0:
			_start_random_attack()


func _update_weak_point_shader() -> void:
	weak_point_marker.visible = weak_point_active


func _start_random_attack() -> void:
	state = State.ATTACKING
	var available: Array = [AttackType.HOMING_MISSILES, AttackType.LASER]
	if enemy_scenes.size() > 0:
		available.append(AttackType.SPAWN)
	var attack: AttackType = available.pick_random()
	match attack:
		AttackType.HOMING_MISSILES: _do_homing_missile_attack()
		AttackType.LASER:           _do_laser_attack()
		AttackType.SPAWN:           _do_spawn_attack()


func _end_attack() -> void:
	state = State.IDLE
	attack_timer = attack_cooldown


func _do_homing_missile_attack() -> void:
	for i in missile_burst_count:
		await get_tree().create_timer(missile_burst_interval).timeout
		_fire_homing_missile()
	_end_attack()


func _fire_homing_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	if missile.has_method("set_target"):
		missile.set_target(player)


func _start_random_missile_loop() -> void:
	random_missile_loop_active = true
	_random_missile_loop_tick()


func _random_missile_loop_tick() -> void:
	if not random_missile_loop_active or not is_inside_tree():
		return

	if randf() < ring_chance:
		await _fire_ring_missiles()
	else:
		for i in random_missile_count:
			await get_tree().create_timer(random_missile_interval).timeout
			if not is_inside_tree():
				return
			_fire_random_missile()

	await get_tree().create_timer(attack_cooldown).timeout
	if is_inside_tree():
		_random_missile_loop_tick()


func _fire_random_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	var random_angle: float = randf() * TAU
	var random_dir: Vector2 = Vector2.from_angle(random_angle)
	missile.rotation = random_angle
	missile.set("move_direction", random_dir)
	if missile.has_method("set_target"):
		missile.set_target(null)
	_tint_missile(missile, random_missile_color)
	_exclude_enemies_from_missile(missile)


func _fire_ring_missiles() -> void:
	if not missile_scene:
		return

	var gap_start: float = randf() * TAU
	var gap_half: float = deg_to_rad(ring_gap_degrees * 0.5)
	var step: float = TAU / float(ring_missile_count)

	for i in ring_missile_count:
		var angle: float = step * i
		var angle_diff: float = abs(wrapf(angle - gap_start, -PI, PI))
		if angle_diff < gap_half:
			continue

		var missile: Node2D = missile_scene.instantiate()
		get_tree().current_scene.add_child(missile)
		missile.global_position = global_position
		var dir: Vector2 = Vector2.from_angle(angle)
		missile.rotation = angle
		missile.set("move_direction", dir)
		if missile.has_method("set_target"):
			missile.set_target(null)
		_tint_missile(missile, Color(1.0, 0.3, 0.0))
		_exclude_enemies_from_missile(missile)

	await get_tree().create_timer(0.1).timeout


func _tint_missile(missile: Node2D, color: Color) -> void:
	missile.modulate = color


func _exclude_enemies_from_missile(missile: Node2D) -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if missile is PhysicsBody2D and enemy is PhysicsBody2D:
			missile.add_collision_exception_with(enemy)
			enemy.add_collision_exception_with(missile)


func _do_laser_attack() -> void:
	if not player:
		_end_attack()
		return

	var base_direction: Vector2 = (player.global_position - global_position).normalized()
	var base_angle: float = base_direction.angle()

	var angles: Array = []
	if laser_count == 1:
		angles.append(base_angle)
	else:
		var spread: float = deg_to_rad(laser_spread_degrees)
		for i in laser_count:
			var t: float = float(i) / float(laser_count - 1)
			angles.append(base_angle + lerp(-spread, spread, t) + randf_range(-deg_to_rad(8), deg_to_rad(8)))

	laser_preview.visible = true
	laser_preview.modulate.a = 0.25
	laser_preview.default_color = Color(1.0, 0.2, 0.2)

	var countdown_steps: int = 4
	var step_duration: float = laser_telegraph_duration / float(countdown_steps)

	for step in countdown_steps:
		var progress: float = float(step + 1) / float(countdown_steps)
		laser_preview.modulate.a = lerp(0.2, 0.85, progress)
		laser_preview.width = lerp(laser_width * 0.3, laser_width * 0.8, progress)
		laser_preview.points = [Vector2.ZERO, Vector2.from_angle(angles[0]) * laser_length]
		await get_tree().create_timer(step_duration).timeout

	laser_preview.visible = false
	laser_beam.default_color = Color(1.0, 0.1, 0.1)
	laser_beam.width = laser_width

	for angle in angles:
		var aim_direction: Vector2 = Vector2.from_angle(angle)
		laser_beam.visible = true
		laser_beam.points = [Vector2.ZERO, aim_direction * laser_length]
		_check_laser_hit(aim_direction)
		await get_tree().create_timer(0.1).timeout
		laser_beam.visible = false
		await get_tree().create_timer(0.04).timeout

	_end_attack()


func _do_spawn_attack() -> void:
	for i in enemy_spawn_count:
		var scene: PackedScene = enemy_scenes.pick_random()
		if not scene:
			continue
		var enemy: Node2D = scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		var angle: float = randf() * TAU
		enemy.global_position = global_position + Vector2.from_angle(angle) * enemy_spawn_radius
		add_collision_exception_with(enemy)
		enemy.add_collision_exception_with(self)
	_end_attack()


func _check_laser_hit(aim_direction: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + aim_direction * laser_length
	)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if result and result.collider == player:
		if player.has_method("take_damage"):
			player.take_damage(1)


func try_hit_weak_point(hit_angle: float) -> bool:
	if not weak_point_active:
		return false
	var angle_diff: float = abs(wrapf(hit_angle - weak_point_angle, -PI, PI))
	if angle_diff <= deg_to_rad(weak_point_angle_width_degrees * 0.5):
		_take_damage(1)
		return true
	return false


func _take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()


func die() -> void:
	random_missile_loop_active = false
	queue_free()
