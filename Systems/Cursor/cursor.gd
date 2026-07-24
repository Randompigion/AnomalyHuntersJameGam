extends Sprite2D
var player
var counter = 0

func _process(_delta: float) -> void:
	position = get_global_mouse_position()
	if Input.is_action_just_pressed("toggle_mode"):
		counter += 1
	if counter % 2 == 0:
		$AnimatedSprite2D.animation = 'Dash'
	else:
		$AnimatedSprite2D.animation = 'Bounce'
