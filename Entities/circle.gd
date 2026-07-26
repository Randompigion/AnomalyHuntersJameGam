extends CharacterBody2D

var player
var direction
var speed = 0
var follow_distance = 150

var is_shield_active: bool = false
@onready var sprite: Node = $Sprite2D if has_node("Sprite2D") else null

func _ready() -> void:
	add_to_group("circle")
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node_or_null("../Entities/Triangle")


func _physics_process(_delta: float) -> void:
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	var path = player.global_position - global_position
	direction = path.normalized()
	if path.length() > follow_distance:
		speed = 700
	else:
		direction = -path.normalized()
		speed = 600
	velocity = direction * speed

	move_and_slide()


func show_shield(active: bool) -> void:
	is_shield_active = active
	if sprite:
		sprite.modulate = Color(1.0, 0.9, 0.2, 1.0) if active else Color(1.0, 1.0, 1.0, 1.0)
