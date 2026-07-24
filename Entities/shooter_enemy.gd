extends CharacterBody2D

const DEATH_SOUNDS := [
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_a.wav"),
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_b.wav"),
]

@export var move_speed: float = 150.0
@export var preferred_distance_min: float = 180.0
@export var preferred_distance_max: float = 260.0
@export var danger_distance: float = 130.0
@export var relocate_check_interval: float = 1.0
@export var candidate_sample_count: int = 8

@export var burst_missile_count: int = 2
@export var burst_interval: float = 0.2
@export var burst_cooldown: float = 4.5

@export var missile_scene: PackedScene

enum State { SEEKING_VANTAGE, HOLDING }
var state: State = State.HOLDING

var player: Node2D
var relocate_timer: float = 0.0
var burst_cooldown_timer: float = 0.0
var burst_shots_remaining: int = 0
var burst_timer: float = 0.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var line_of_sight_ray: RayCast2D = $LineOfSightRay


func _ready() -> void:
	player = $"../Triangle"
	add_to_group("enemy")
	_pick_new_vantage_point()


func _physics_process(delta: float) -> void:
	if not player:
		return

	relocate_timer -= delta
	burst_cooldown_timer -= delta

	match state:
		State.SEEKING_VANTAGE:
			_process_moving(delta)
		State.HOLDING:
			_process_holding(delta)

	_check_should_relocate()


func _process_moving(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
		state = State.HOLDING
		velocity = Vector2.ZERO
		return

	var next_path_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_path_pos)
	velocity = direction * move_speed
	move_and_slide()
	rotation = direction.angle()


func _process_holding(delta: float) -> void:
	velocity = Vector2.ZERO
	rotation = global_position.angle_to_point(player.global_position)

	if burst_shots_remaining > 0:
		burst_timer -= delta
		if burst_timer <= 0.0:
			_fire_missile()
			burst_shots_remaining -= 1
			burst_timer = burst_interval
	elif burst_cooldown_timer <= 0.0 and _has_line_of_sight():
		burst_shots_remaining = burst_missile_count
		burst_timer = 0.0
		burst_cooldown_timer = burst_cooldown


func _check_should_relocate() -> void:
	if state == State.HOLDING:
		var distance_to_player: float = global_position.distance_to(player.global_position)
		if distance_to_player < danger_distance:
			_pick_new_vantage_point()
			return

	if relocate_timer <= 0.0:
		relocate_timer = relocate_check_interval
		if state == State.HOLDING and not _has_line_of_sight():
			_pick_new_vantage_point()


func _pick_new_vantage_point() -> void:
	var best_point: Vector2 = global_position
	var best_score: float = -INF

	for i in candidate_sample_count:
		var angle: float = randf() * TAU
		var distance: float = randf_range(preferred_distance_min, preferred_distance_max)
		var candidate: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * distance

		var score: float = _score_candidate(candidate)
		if score > best_score:
			best_score = score
			best_point = candidate

	nav_agent.target_position = best_point
	state = State.SEEKING_VANTAGE


func _score_candidate(candidate: Vector2) -> float:
	var distance_to_player: float = candidate.distance_to(player.global_position)
	if distance_to_player < preferred_distance_min or distance_to_player > preferred_distance_max:
		return -1000.0

	line_of_sight_ray.global_position = candidate
	line_of_sight_ray.target_position = player.global_position - candidate
	line_of_sight_ray.force_raycast_update()

	var has_sight: bool = not line_of_sight_ray.is_colliding()
	var score: float = 0.0
	if has_sight:
		score += 500.0
	score -= abs(distance_to_player - ((preferred_distance_min + preferred_distance_max) * 0.5))
	return score


func _has_line_of_sight() -> bool:
	line_of_sight_ray.global_position = global_position
	line_of_sight_ray.target_position = player.global_position - global_position
	line_of_sight_ray.force_raycast_update()
	return not line_of_sight_ray.is_colliding()


func _fire_missile() -> void:
	if not missile_scene:
		return
	var missile: Node2D = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	missile.global_position = global_position
	if missile.has_method("set_target"):
		missile.set_target(player)


func die() -> void:
	$"../Triangle/Camera2D2".trigger_shake()
	Sfx.play(DEATH_SOUNDS.pick_random())
	$"../../TimeLeft".add_time(10)
	queue_free()
	
	
