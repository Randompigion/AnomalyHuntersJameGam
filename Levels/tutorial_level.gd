extends Node2D

const narrator_lines = {
	1: "yo what's up, i'm the uhh.... the narrator.",
	2: "yeahh, the other guy kinda spontaneously combusted. i don't know what's up with that.",
	3: "anyways! you should totally like use your w a s d keys to move.",
	4: "oh yeah, you can dash by the way. move your mouse cursor where you want to dash to, and just left click. simple as that!",
	5: "you can toggle into bounce mode by right clicking. then, point and left click to dash into a surface, and you'll bounce right off it! neat, right?",
	6: "now, use what you've learned to kill this - sound warning by the way - EXTREMELY WEAK ENEMY!",
}

var queued_lines = []
var played_lines = {}
var speaking = false


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_queue_line(1)
	_queue_line(2)
	_queue_line(3)


func _queue_line(index: int) -> void:
	if played_lines.has(index) or queued_lines.has(index):
		return
	queued_lines.append(index)
	_drain_queue()


func _drain_queue() -> void:
	if speaking:
		return
	speaking = true
	while not queued_lines.is_empty():
		var index = queued_lines.pop_front()
		played_lines[index] = true
		var player = get_node("AudioTriggers/Narrator%d" % index)
		await NarratorSubtitle.speak(self, player, narrator_lines[index])
	speaking = false


func _on_narrator_2_trigger_body_entered(body: Node2D) -> void:
	_queue_line(2)


func _on_narrator_5_trigger_body_entered(body: Node2D) -> void:
	_queue_line(5)


func _on_narrator_6_trigger_body_entered(body: Node2D) -> void:
	_queue_line(6)
