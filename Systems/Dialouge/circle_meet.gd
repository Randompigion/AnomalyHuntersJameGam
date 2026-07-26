extends Node2D
var dialogue_text =  [""]
var dialogue_speaker =  [""]
var dialogue_sprite =  [""]
const textboxlocation = preload("res://Systems/Dialouge/DialougeManager.tscn")


# I've set it so you just need to change the parameters and give that signal
#Give it a signal and a copy of this text and itll work!
func start():
	var textbox = textboxlocation.instantiate()
	dialogue_text =  ["Dialouge for triangle meeting circle", "Yay im here now"]
	dialogue_speaker =  ["Triangle", "Circle"]
	dialogue_sprite =  ["Triangle", "Circle"]
	textbox.newDialouge(dialogue_text,dialogue_speaker,dialogue_sprite)
	add_child(textbox)
