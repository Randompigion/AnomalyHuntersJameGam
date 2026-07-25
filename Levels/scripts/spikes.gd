extends Area2D

func _ready() -> void:
	add_to_group("hazard")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("hazard_kill"):
		body.hazard_kill()
	elif body.has_method("die"):
		body.die()
