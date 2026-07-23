extends Node2D

func hyper_time(): 
	_on_hyper_timer_timeout()
	Engine.time_scale = 1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hyper_timer_timeout() -> void:
	Engine.time_scale = 0.05
