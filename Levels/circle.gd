extends CharacterBody2D
@onready var triangle = $"../Triangle"
var direction: Vector2 = Vector2.ZERO
const SPEED = 1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction = (triangle.position - position).normalized()
	velocity = direction * SPEED
	move_and_slide()
