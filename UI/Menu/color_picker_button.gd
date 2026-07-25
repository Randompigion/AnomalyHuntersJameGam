extends ColorPickerButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var picker = get_picker()
	picker.custom_maximum_size = Vector2(500, 400)
