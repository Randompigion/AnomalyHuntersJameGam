extends CharacterBody2D

var player
var direction
const SPEED = 750

func _ready() -> void:
	player = get_node_or_null("../Triangle") 

func _physics_process(delta: float) -> void:
	if player:
		direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		
	move_and_slide()
