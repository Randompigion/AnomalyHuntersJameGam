extends Node

## Autoload for one-shot sounds that must outlive the node that triggered them
## (e.g. an enemy death, where the emitter is queue_free()'d on the same frame).
## Register as autoload "Sfx". Call Sfx.play(some_stream).
func play(stream: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
