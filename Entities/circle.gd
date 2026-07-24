extends CharacterBody2D

var player
var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var follow_distance: float = 150.0
var deadzone: float = 20.0

var reaction_delay: float = 0.15
var reaction_timer: float = 0.0
var pending_direction: Vector2 = Vector2.ZERO
var pending_speed: float = 0.0


func _ready() -> void:
	player = get_node_or_null("../Entities/Triangle")


func _physics_process(delta: float) -> void:
	if player:
		var path: Vector2 = player.global_position - global_position
		var distance: float = path.length()

		if distance > follow_distance + deadzone:
			pending_direction = path.normalized()
			pending_speed = 500.0
		elif distance < follow_distance - deadzone:
			pending_direction = -path.normalized()
			pending_speed = 200.0
		else:
			pending_direction = Vector2.ZERO
			pending_speed = 0.0

		reaction_timer -= delta
		if reaction_timer <= 0.0:
			direction = pending_direction
			speed = pending_speed
			reaction_timer = reaction_delay

	velocity = direction * speed
	move_and_slide()
