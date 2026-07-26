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
