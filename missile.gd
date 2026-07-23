extends Area2D

const SPEED: float = 380.0
const TURN_RATE_DEGREES: float = 220.0
const LIFETIME: float = 4.0

var target: Node2D
var move_direction: Vector2 = Vector2.RIGHT
var life_timer: float = 0.0


func _ready() -> void:
	life_timer = LIFETIME
	body_entered.connect(_on_body_entered)


func set_target(new_target: Node2D) -> void:
	target = new_target
	if target:
		move_direction = global_position.direction_to(target.global_position)
		rotation = move_direction.angle()


func _physics_process(delta: float) -> void:
	life_timer -= delta
	if life_timer <= 0.0:
		queue_free()
		return

	if target and is_instance_valid(target):
		var desired_direction: Vector2 = global_position.direction_to(target.global_position)
		var angle_diff: float = move_direction.angle_to(desired_direction)
		var max_turn: float = deg_to_rad(TURN_RATE_DEGREES) * delta
		move_direction = move_direction.rotated(clampf(angle_diff, -max_turn, max_turn))

	global_position += move_direction * SPEED * delta
	rotation = move_direction.angle()


func _on_body_entered(body: Node) -> void:
	if body.has_method("get_stunned"):
		body.get_stunned()
	queue_free()
