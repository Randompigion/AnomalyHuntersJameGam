extends CharacterBody2D

@export var max_hp: int = 5
var hp: int

@export var attack_cooldown: float = 2.5
@export var weak_point_angle_width_degrees: float = 60.0
@export var weak_point_rotation_speed_degrees: float = 25.0
@export var weak_point_active_duration: float = 2.0
@export var weak_point_inactive_duration: float = 1.5

@export var missile_scene: PackedScene
@export var missile_burst_count: int = 5
@export var missile_burst_interval: float = 0.15

@export var laser_telegraph_duration: float = 0.8
@export var laser_active_duration: float = 0.3
@export var laser_length: float = 2000.0
@export var laser_count: int = 4
@export var laser_spread_degrees: float = 30.0

@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_spawn_count: int = 3
@export var enemy_spawn_radius: float = 200.0

enum AttackType { MISSILES, LASER, SPAWN }
enum State { IDLE, ATTACKING }
var state: State = State.IDLE

var player: Node2D
var weak_point_angle: float = 0.0
var attack_timer: float = 0.0
var weak_point_active: bool = true
var weak_point_timer: float = 0.0

@onready var laser_preview: Line2D = $LaserPreview
@onready var laser_beam: Line2D = $LaserBeam
@onready var weak_point_marker: Node2D = $WeakPointMarker


func _ready() -> void:
	hp = max_hp
	add_to_group("boss")
	attack_timer = attack_cooldown
	laser_preview.visible = false
	laser_beam.visible = false
	weak_point_timer = weak_point_active_duration
	_update_weak_point_shader()


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
	var available: Array = [AttackType.MISSILES, AttackType.LASER]
	if enemy_scenes.size() > 0:
		available.append(AttackType.SPAWN)
	var attack: AttackType = available.pick_random()
	match attack:
		AttackType.MISSILES: _do_missile_attack()
		AttackType.LASER:    _do_laser_attack()
		AttackType.SPAWN:    _do_spawn_attack()


func _end_attack() -> void:
	state = State.IDLE
	attack_timer = attack_cooldown


func _do_missile_attack() -> void:
	for i in missile_burst_count:
		await get_tree().create_timer(missile_burst_interval).timeout
		_fire_missile()
	_end_attack()


func _fire_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	if missile.has_method("set_target"):
		missile.set_target(player)


func _do_laser_attack() -> void:
	var base_direction: Vector2 = (player.global_position - global_position).normalized()
	var base_angle: float = base_direction.angle()

	var angles: Array = []
	if laser_count == 1:
		angles.append(base_angle)
	else:
		var spread: float = deg_to_rad(laser_spread_degrees)
		for i in laser_count:
			var t: float = float(i) / float(laser_count - 1)
			angles.append(base_angle + lerp(-spread, spread, t) + randf_range(-deg_to_rad(10), deg_to_rad(10)))

	laser_preview.visible = true
	laser_preview.modulate.a = 0.35
	laser_preview.points = [Vector2.ZERO, Vector2.from_angle(angles[0]) * laser_length]

	await get_tree().create_timer(laser_telegraph_duration).timeout

	laser_preview.visible = false

	for angle in angles:
		var aim_direction: Vector2 = Vector2.from_angle(angle)
		laser_beam.visible = true
		laser_beam.points = [Vector2.ZERO, aim_direction * laser_length]
		_check_laser_hit(aim_direction)
		await get_tree().create_timer(0.08).timeout
		laser_beam.visible = false
		await get_tree().create_timer(0.05).timeout

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
	queue_free()
