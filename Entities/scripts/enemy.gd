extends CharacterBody2D
var player
var direction
const SPEED = 200
var can_damage = true
const DEATH_SOUNDS := [
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_a.wav"),
	preload("res://Assets/Audio/SFX/Enemies/sfx_enemy_death_b.wav"),
]
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
		direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		
	move_and_slide()
	
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
