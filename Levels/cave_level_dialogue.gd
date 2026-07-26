extends Node2D

const timer_explanation = preload("res://Assets/Audio/NarratorVoiceLines/NewSecondLevel/TimerExplanation_converted_by_soundandgo.com_.mp3")

@onready var voice: AudioStreamPlayer = $NarratorVoice


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	await NarratorSubtitle.speak(self, voice, timer_explanation, [
		"Hey! It seemed like in that last level, that when you killed an enemy, the timer reduced a bit.",
		"And when you got stunned, it reduced even more. Be careful not to get hit!",
	])
