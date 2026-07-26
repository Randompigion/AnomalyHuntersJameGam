extends Node2D

const spilled_water = preload("res://Assets/Audio/NarratorVoiceLines/NewTutorialLevel/SpilledWater(Last Line).mp3")

var triggeredbefore = false

@export var target_scene_path: String = "res://Levels/cave_level.tscn"
@export var only_player: bool = true


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if only_player and body.name != "Triangle":
		return
	if target_scene_path == "":
		push_warning("SceneChangeZone: no se ha asignado target_scene_path")
		return
	if triggeredbefore == false:
		triggeredbefore = true
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		await NarratorSubtitle.speak(self, voice, spilled_water, [
			"Wait, did the developer just spill his coffee on his laptop???",
		])
		voice.queue_free()
		get_tree().change_scene_to_file("res://Levels/forest_level.tscn")
