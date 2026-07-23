extends Node

@onready var label = $Label 
@onready var timer = $Timer

func _ready() -> void:
	timer.start()
	
func time_left_to_live():
	var time_left = timer.time_left
	var min = floor(time_left/60)
	var sec = int(time_left) % 60
	if time_left <= 0:
		print("GAME OVER")
		get_tree().reload_current_scene()
	return [min,sec]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "%02d:%02d" % time_left_to_live()
