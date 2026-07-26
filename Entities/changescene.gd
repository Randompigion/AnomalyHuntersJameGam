extends Node2D
var triggeredbefore = false

@export var target_scene_path: String = "res://Levels/change_scene.tscn"
@export var only_player: bool = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if only_player and body.name != "Triangle":
		return
	if target_scene_path == "":
		push_warning("SceneChangeZone: no se ha asignado target_scene_path")
		return
	get_tree().change_scene_to_file("res://Levels/cave_level.tscn")
