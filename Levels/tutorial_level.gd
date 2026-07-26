extends Node2D

const voice_path = "res://Assets/Audio/NarratorVoiceLines/NewTutorialLevel/"

#One entry per voice line file, in the order they play. Several subtitles can share one clip.
const narrator_beats = [
	{
		"stream": preload(voice_path + "Intoduction(FirstLine).mp3"),
		"lines": [
			"Hey user, uhh I'm the narrator and welcome to the game.",
			"You can hold your w key and point with your cursor to move.",
			"By pointing and left clicking you can dash. But don't dash into a wall, it'll stun you.",
		],
	},
	{
		"stream": preload(voice_path + "GoThroughFirstPortal.mp3"),
		"lines": [
			"Go through the portal when you're ready to learn some more moves.",
		],
	},
	{
		"stream": preload(voice_path + "DashVsBounceMode.mp3"),
		"lines": [
			"By right-clicking you can toggle between 'Dash Mode' and 'Bounce Mode'.",
			"In bounce mode you can dash into a wall and bounce off of it before you get stunned.",
			"You can also use bounce mode to interact with objects.",
			"Go through the next portal to learn some more about interacting with objects!",
		],
	},
	{
		"stream": preload(voice_path + "SpikeWall.mp3"),
		"lines": [
			"This is a spike wall, in dash mode you can't interact with it, but in bounce mode you can move into the wall to rotate it.",
			"By bouncing into the wall you can launch the spike wall, this will come in handy to kill certain enemies.",
		],
	},
	{
		"stream": preload(voice_path + "PauseMenu.mp3"),
		"lines": [
			"Oh and also, I almost forgot - you can press escape to access your pause menu.",
		],
	},
	{
		"stream": preload(voice_path + "ThirdBoxPortal.mp3"),
		"lines": [
			"Go through the next portal to fight your first enemy!",
		],
	},
	{
		"stream": preload(voice_path + "TutorialEnemy.mp3"),
		"lines": [
			"This enemy is the tutorial enemy, he's kinda like the weakest thing in the game.",
			"You can kill this enemy by dashing into it.",
			"He can stun you if you get too close without dashing, so watch out!",
		],
	},
	{
		"stream": preload(voice_path + "UseWhatYou'veLearned.mp3"),
		"lines": [
			"Okay, now use what you've learned to kill this enemy.",
		],
	},
]

var queued_beats = []
var played_beats = {}
var speaking = false

@onready var voice: AudioStreamPlayer = $AudioTriggers/NarratorVoice


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_queue_beats([0, 1])


func _queue_beats(indices: Array) -> void:
	for index in indices:
		if played_beats.has(index) or queued_beats.has(index):
			continue
		queued_beats.append(index)
	_drain_queue()


func _drain_queue() -> void:
	if speaking:
		return
	speaking = true
	while not queued_beats.is_empty():
		var index = queued_beats.pop_front()
		played_beats[index] = true
		var beat = narrator_beats[index]
		await NarratorSubtitle.speak(self, voice, beat["stream"], beat["lines"])
	speaking = false


func _on_narrator_4_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_queue_beats([2])


func _on_narrator_5_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_queue_beats([3, 4, 5])


func _on_narrator_6_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_queue_beats([6, 7])
