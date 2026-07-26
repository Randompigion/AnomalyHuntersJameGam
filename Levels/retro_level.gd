extends Node2D

const voice_path = "res://Assets/Audio/NarratorVoiceLines/NewFirstLevel/"

#One entry per voice line file, in the order they play. Several subtitles can share one clip.
const narrator_beats = [
	{
		"stream": preload(voice_path + "WhereAreWe_FirstLine__converted_by_soundandgo.com_.mp3"),
		"lines": [
			"Hey, I'm back! I bet you thought I was gone for good, didn't you.",
			"Wait, where are we? This isn't the game.",
		],
	},
	{
		"stream": preload(voice_path + "WhatIsThatTimer_SecondLine__converted_by_soundandgo.com_.mp3"),
		"lines": [
			"What's that timer, \"time left until full corruption? That doesn't sound good!\"",
			"I think we have to get out of here before it hits zero!",
		],
	},
	{
		"stream": preload(voice_path + "FightForwards_ThirdLine__converted_by_soundandgo.com_.mp3"),
		"lines": [
			"I guess we have no choice but to fight our way forwards.",
		],
	},
	{
		"stream": preload(voice_path + "InventoryUsage_AfterGettingUpgradesByCircle__converted_by_soundandgo.com_.mp3"),
		"lines": [
			"Open up the upgrade menu looking thing!",
			"It looks like those red slots are where you put in upgrades for the user.",
			"Try clicking on an upgrade and moving it into a different slot to see how it works.",
		],
	},
	{
		"stream": preload(voice_path + "LetsGo_AtEndOfLevel__converted_by_soundandgo.com_.mp3"),
		"lines": [
			"Nice job! I can see the portal right there, let's go!",
		],
	},
]

var queued_beats = []
var played_beats = {}
var speaking = false
var enemies_seen = false
var cleared_line_queued = false

@onready var voice: AudioStreamPlayer = $NarratorVoice


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_queue_beats([0, 1, 2])


#The last two lines react to the fight being over, so they wait for the level to be emptied.
func _process(_delta: float) -> void:
	if cleared_line_queued:
		return
	var enemies_left = get_tree().get_nodes_in_group("enemy").size()
	if enemies_left > 0:
		enemies_seen = true
	elif enemies_seen:
		cleared_line_queued = true
		_queue_beats([3, 4])


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
