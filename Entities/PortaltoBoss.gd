extends Node2D

@export var target_scene_path: String = "res://Entities/boss_fight.tscn"
@export var only_player: bool = true

var triggeredbefore = false


func _ready() -> void:
	for child in get_children():
		if child is Area2D and not child.body_entered.is_connected(_on_body_entered):
			child.body_entered.connect(_on_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_on_body_entered(body)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	_on_body_entered(body)


func _on_body_entered(body: Node2D) -> void:
	if triggeredbefore:
		return
	if only_player and not body.is_in_group("player") and body.name != "Triangle":
		return
	if target_scene_path == "":
		push_error("PortalToBoss: no target_scene_path assigned")
		return
	var packed := load(target_scene_path) as PackedScene
	if packed == null:
		push_error("PortalToBoss: could not load " + target_scene_path)
		return
	triggeredbefore = true
	get_tree().call_deferred("change_scene_to_packed", packed)
