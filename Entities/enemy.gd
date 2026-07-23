extends CharacterBody2D
var player
var direction
const SPEED = 50

func _ready() -> void:
	player = $"../Triangle"
	add_to_group("enemy")

func _on_kill_zone_body_entered(body: Node2D) -> void:
	die()

func die():
	queue_free()

func _physics_process(delta: float) -> void:
	if player:
		direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
	move_and_slide()
