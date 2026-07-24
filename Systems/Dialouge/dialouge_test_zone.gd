extends Node2D
var dialogue_text =  [""]
var dialogue_speaker =  [""]
var dialogue_sprite =  [""]
const textboxlocation = preload("res://Systems/Dialouge/DialougeManager.tscn")


# I've set it so you just need to change the parameters and give that signal
#Give it a signal and a copy of this text and itll work!
func _ready() -> void:
	var textbox = textboxlocation.instantiate()
	dialogue_text =  ["This is a simple text", "This is another text", "Circle should speak", "Boss Speaks"]
	dialogue_speaker =  ["Triangle", "Triangle", "Circle", "Boss"]
	dialogue_sprite =  ["Triangle", "Triangle", "Circle", "Boss"]
	textbox.newDialouge(dialogue_text,dialogue_speaker,dialogue_sprite)
	add_child(textbox)
