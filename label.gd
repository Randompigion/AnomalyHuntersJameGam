extends Label
var timerwork = false
var textspeed = 23.0
var line_durations : Array = []
var line_elapsed = 0.0
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

#Subtitles for one voice line. Several strings share the clip, split by how long each one is.
func newVoiceline(Lines,Speaker,Sprite,duration):
	var speakers = []
	var sprites = []
	for i in Lines.size():
		speakers.append(Speaker)
		sprites.append(Sprite)
	line_durations = _split_duration(Lines, duration)
	line_elapsed = 0.0
	newDialouge(Lines,speakers,sprites)
	auto_advance = true


func _split_duration(Lines, duration: float) -> Array:
	var total = 0
	for line in Lines:
		total += max(line.length(), 1)
	var out = []
	for line in Lines:
		out.append(duration * max(line.length(), 1) / total)
	return out

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
	if auto_advance:
		return max(_current_duration() * 0.75, 0.1)
	return max(text.length(), 1) / textspeed


func _current_duration() -> float:
	if dialogue_index < line_durations.size():
		return line_durations[dialogue_index]
	return 0.0

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
		if auto_advance:
			line_elapsed += delta
			if line_elapsed >= _current_duration():
				dialogue_index += 1
				progress = 0.0
				line_elapsed = 0.0
				showline()
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

#NOTES (Keep at bottom):
#if you want to change the spites or add more, they're a spriteframe. You can even do animations!
#This depends on another scene triggering it, but i made the code for anything to do that in dialouge test zone
#It doesn't freeze time, since idk how to do that. Sorry
