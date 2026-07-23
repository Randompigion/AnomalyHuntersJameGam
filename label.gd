extends Label
var timerwork = false
var textspeed = 0.05
#var sprite_location = "left"
#I planned to make it so the sprite would move based on who's talking, but didn't code it.
var dialogue_text : Array = []
var dialogue_speaker : Array = []
var dialogue_sprite : Array = []
var dialogue_index = 0
var progress = 0

#Whenever you want to start a dialouge, you need to give it these parameters. Its explained in DialougeTestZone.tscn
func newDialouge(Text,Speaker,Sprite):
	dialogue_text = (Text)
	dialogue_speaker =  (Speaker)
	dialogue_sprite =  (Sprite)

#Adds a delay so you don't skip all the lines when you press!
func newline():
	if Input.is_action_just_pressed("NextDialouge"):
		%Delay.start()


# If there's still lines, gradually make the text show up. If not, delete this node.
func _process(delta: float) -> void:
	if dialogue_index < dialogue_text.size():
		text = dialogue_text[dialogue_index]
		%NameLabel.text = dialogue_speaker[dialogue_index]
		%Sprite.animation = dialogue_sprite[dialogue_index]
		if progress < 1:
			progress += textspeed
			visible_ratio = 0 + progress
		else:
			newline()
	else:
		text = ""
		%NameLabel.text = ""
		%Sprite.animation = "Null"
		visible_ratio = 0
		queue_free()

# Waits until the delay is over to start a new line
func _on_delay_timeout() -> void:
	dialogue_index += 1
	progress = 0

#NOTES (Keep at bottom):
#if you want to change the spites or add more, they're a spriteframe. You can even do animations!
#This depends on another scene triggering it, but i made the code for anything to do that in dialouge test zone
#It doesn't freeze time, since idk how to do that. Sorry
