extends Node2D



func hyper_time(): 
	Engine.time_scale = 0.05
	_on_hyper_timer_timeout()

func _on_hyper_timer_timeout() -> void:
	Engine.time_scale = 1
