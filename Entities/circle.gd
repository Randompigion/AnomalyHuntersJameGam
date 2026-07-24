extends CharacterBody2D

var player
var direction
var speed = 0
var follow_distance = 150

func _ready() -> void:
	player = get_node_or_null("../Entities/Triangle") 


func _physics_process(delta: float) -> void:
	if player:
		var path = player.global_position - global_position
		direction = path.normalized()
		if path.length() > follow_distance:
			speed = 500
		else:
			direction = -path.normalized()
			speed = 200
		velocity = direction * speed
		
	move_and_slide()
