extends Label
var timerwork = false
var textspeed = 23.0
var reveal_time = 0.0
#var sprite_location = "left"
#I planned to make it so the sprite would move based on who's talking, but didn't code it.
var dialogue_text : Array = []
var dialogue_speaker : Array = []
var dialogue_sprite : Array = []
var dialogue_index = 0
var progress = 0.0
var auto_advance = false

#Whenever you want to start a dialouge, you need to give it these parameters. Its explained in DialougeTestZone.tscn
func newDialouge(Text,Speaker,Sprite):
	dialogue_text = (Text)
	dialogue_speaker =  (Speaker)
	dialogue_sprite =  (Sprite)
	dialogue_index = 0
	progress = 0.0
	showline()

func newVoiceline(Text,Speaker,Sprite,Player):
	newDialouge([Text],[Speaker],[Sprite])
	auto_advance = true
	if is_instance_valid(Player):
		if Player.stream:
			reveal_time = Player.stream.get_length() * 0.75
		Player.finished.connect(_on_voiceline_finished, CONNECT_ONE_SHOT)

#Puts the line on screen hidden, so it never flashes fully typed before it starts typing
func showline():
	if dialogue_index >= dialogue_text.size():
		return
	text = dialogue_text[dialogue_index]
	var speaker = get_node_or_null("NameLabel")
	if speaker:
		speaker.text = dialogue_speaker[dialogue_index]
	var portrait = get_node_or_null("Sprite")
	if portrait:
		portrait.animation = dialogue_sprite[dialogue_index]
	visible_ratio = 0

#How long the whole line takes to type out
func linetime() -> float:
	if reveal_time > 0:
		return reveal_time
	return max(text.length(), 1) / textspeed

#Adds a delay so you don't skip all the lines when you press!
func newline():
	if Input.is_action_just_pressed("NextDialouge"):
		%Delay.start()


# If there's still lines, gradually make the text show up. If not, delete this node.
func _process(delta: float) -> void:
	if dialogue_index < dialogue_text.size():
		if progress < 1:
			progress += delta / linetime()
			visible_ratio = min(progress, 1.0)
		elif not auto_advance:
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
	progress = 0.0
	showline()


func _on_voiceline_finished() -> void:
	dialogue_index += 1
	progress = 0.0
	showline()

#NOTES (Keep at bottom):
#if you want to change the spites or add more, they're a spriteframe. You can even do animations!
#This depends on another scene triggering it, but i made the code for anything to do that in dialouge test zone
#It doesn't freeze time, since idk how to do that. Sorry
