extends CharacterBody2D
var player
var direction
const SPEED = 200
const PUSH_FORCE = 1.0
var can_damage = true
var path_update_timer: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.3
const TURN_RATE: float = 8.0
var current_direction: Vector2 = Vector2.RIGHT
const DEATH_SOUNDS := [
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_a.wav"),
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_b.wav"),
]
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().root.find_child("Triangle", true, false)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body == player:
		if player.dashing and player.mode == player.Mode.DASH:
			die()
		else:
			if can_damage:
				player.take_damage(1)
				can_damage = false
				$AttackCooldown.start()

func die():
	Sfx.play(DEATH_SOUNDS.pick_random())
	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.add_time(10)
	if player and player.has_node("Camera2D2"):
		player.get_node("Camera2D2").trigger_shake()
	queue_free()

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	path_update_timer -= delta
	if path_update_timer <= 0.0:
		path_update_timer = PATH_UPDATE_INTERVAL
		nav_agent.target_position = player.global_position
	if not nav_agent.is_navigation_finished():
		var next_path_pos: Vector2 = nav_agent.get_next_path_position()
		var target_direction: Vector2 = global_position.direction_to(next_path_pos)
		current_direction = current_direction.lerp(target_direction, TURN_RATE * delta).normalized()
		direction = current_direction
		var desired_velocity: Vector2 = direction * SPEED
		nav_agent.set_velocity(desired_velocity)
	else:
		nav_agent.set_velocity(Vector2.ZERO)
	rotation = global_position.angle_to_point(player.global_position)
	var impact_velocity = velocity
	move_and_slide()
	Push.apply_slides(self, impact_velocity, PUSH_FORCE)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider == player:
			if not (player.dashing and player.mode == player.Mode.DASH) and player.has_method("take_damage"):
				if can_damage:
					player.take_damage(1)
					can_damage = false
					$AttackCooldown.start()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_attack_cooldown_timeout() -> void:
	can_damage = true
