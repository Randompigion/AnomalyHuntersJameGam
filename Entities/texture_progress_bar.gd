extends TextureProgressBar

@onready var timer: Timer = $"../dash_cooldown"

func _ready() -> void:
	max_value = timer.wait_time
	value = timer.wait_time

func _process(delta: float) -> void:
	value = timer.time_left 
