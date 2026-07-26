class_name NarratorSubtitle
extends RefCounted

const textboxlocation = preload("res://Systems/Dialouge/DialougeManager.tscn")
const design_zoom = 0.5


static func speak(host: Node, player: AudioStreamPlayer, line: String) -> void:
	if not is_instance_valid(host) or not is_instance_valid(player) or not host.is_inside_tree():
		return

	var layer := CanvasLayer.new()
	layer.layer = 2

	var screen := Control.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(screen)

	var middle := Control.new()
	middle.set_anchors_preset(Control.PRESET_CENTER)
	middle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	middle.scale = Vector2(design_zoom, design_zoom)
	screen.add_child(middle)

	var textbox := textboxlocation.instantiate()
	player.play()
	textbox.newVoiceline(line, "Narrator", "Null", player)
	middle.add_child(textbox)
	host.add_child(layer)

	await player.finished
	layer.queue_free()
