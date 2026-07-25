extends CanvasLayer

## Pause overlay. Drop this scene into a level and the "pause" action toggles it.
## Keeps processing while the tree is paused so the menu stays interactive.

@onready var menu: Control = $Menu

var is_paused: bool = false


func _ready() -> void:
	visible = false
	menu.resume_requested.connect(resume)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle()
		get_viewport().set_input_as_handled()


func toggle() -> void:
	if is_paused:
		resume()
	else:
		pause()


func pause() -> void:
	is_paused = true
	visible = true
	get_tree().paused = true
	set_game_cursor_visible(false)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func resume() -> void:
	is_paused = false
	visible = false
	get_tree().paused = false
	set_game_cursor_visible(true)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# The in-game cursor is a world sprite that freezes while paused, so swap it
# for the OS cursor instead of leaving a stuck sprite behind the menu.
func set_game_cursor_visible(is_visible: bool) -> void:
	for cursor in get_tree().get_nodes_in_group("game_cursor"):
		cursor.visible = is_visible
