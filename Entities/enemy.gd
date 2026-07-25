extends CharacterBody2D

var player
var direction
const SPEED = 200
const PUSH_FORCE = 1.0
var can_damage = true
var path_update_timer: float = 0.0
const PATH_UPDATE_INTERVAL: float = 0.3

const DEATH_SOUNDS := [
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_a.wav"),
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_b.wav"),
]

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	player = get_node_or_null("../Entities/Triangle")
	add_to_group("enemy")


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
	$"../TimeLeft".add_time(10)
	$"../Entities/Triangle/Camera2D2".trigger_shake()
	queue_free()


func _physics_process(delta: float) -> void:
	if player:
		path_update_timer -= delta
		if path_update_timer <= 0.0:
			path_update_timer = PATH_UPDATE_INTERVAL
			nav_agent.target_position = player.global_position

		if not nav_agent.is_navigation_finished():
			var next_path_pos: Vector2 = nav_agent.get_next_path_position()
			direction = global_position.direction_to(next_path_pos)
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO

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


func _on_attack_cooldown_timeout() -> void:
	can_damage = true
