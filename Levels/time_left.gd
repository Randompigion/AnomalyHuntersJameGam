extends Node

@onready var label = $Label

var time_left: float = 120.0

func _ready() -> void:
	pass
	
func time_left_to_live():
	var minutes = floor(time_left/60)
	var sec = int(time_left) % 60
	if time_left <= 0:
		print("GAME OVER")
		get_tree().reload_current_scene()
	return [minutes,sec]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_left -= delta
	label.text = "%02d:%02d" % time_left_to_live()

func add_time(x):
	time_left += x
