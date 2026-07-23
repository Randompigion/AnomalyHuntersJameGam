extends CharacterBody2D

@export var speed = 300.0
@export var dash_speed = 3000
@export var friction = 2

var dashing = false
var direction: Vector2 = Vector2.ZERO
var can_move = true
var can_dash = true

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	direction = Input.get_vector("left","right","up","down")
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		$AudioStreamPlayer2D.play()
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
		
	if can_move:	
		if dashing:
			var vector = get_global_mouse_position() - global_position
			velocity = dash_speed * vector.normalized()
		else:
			velocity = speed * direction
	move_and_slide()
	


func _on_dash_timer_timeout() -> void:
	dashing = false # Replace with function body.


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
