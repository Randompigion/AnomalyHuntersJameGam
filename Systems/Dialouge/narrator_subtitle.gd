class_name NarratorSubtitle
extends RefCounted

const textboxlocation = preload("res://Systems/Dialouge/DialougeManager.tscn")
const design_zoom = 0.5
const read_speed = 15.0


static func speak(host: Node, player: AudioStreamPlayer, stream: AudioStream, lines: Array) -> void:
	if not is_instance_valid(host) or not host.is_inside_tree() or lines.is_empty():
		return

	var voiced := stream != null and is_instance_valid(player)
	var duration := stream.get_length() if voiced else _reading_time(lines)

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
	if voiced:
		player.stream = stream
		player.play()
	textbox.newVoiceline(lines, "Narrator", "Null", duration)
	middle.add_child(textbox)
	host.add_child(layer)

	if voiced:
		await player.finished
	else:
		await host.get_tree().create_timer(duration).timeout
	layer.queue_free()


static func _reading_time(lines: Array) -> float:
	var characters := 0
	for line in lines:
		characters += line.length()
	return max(2.0, characters / read_speed)
