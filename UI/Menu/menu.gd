extends Control

## Emitted when the player asks to close the menu. The PauseMenu overlay
## listens for this and unpauses the tree.
signal resume_requested

@onready var panels: Control = %Panels
@onready var main_buttons: Control = %MainButtons
@onready var menu_label: Label = %MenuLabel
@onready var play_panel: Panel = %PlayPanel
@onready var volume_panel: Panel = %VolumePanel
@onready var settings_panel: Panel = %SettingsPanel
@onready var skills_panel: Panel = %SkillsPanel
@onready var settings_button: TextureButton = %SettingsButton
@onready var volume_button: TextureButton = %VolumeButton
@onready var play_button: TextureButton = %PlayButton
@onready var skills_button: TextureButton = %SkillsButton
@onready var settings_og_position: Vector2 = settings_button.position
@onready var volume_og_position: Vector2 = volume_button.position
@onready var play_og_position: Vector2 = play_button.position
@onready var skills_og_position: Vector2 = skills_button.position
@onready var menu = menu_label.get_owner()
@onready var back_sfx: AudioStreamPlayer2D = $SfxUiBack
@onready var error_sfx: AudioStreamPlayer2D = $SfxUiError
@onready var hover_sfx: AudioStreamPlayer2D = $SfxUiHover
@onready var select_sfx: AudioStreamPlayer2D = $SfxUiSelect

@export var shake: float = 4.0
@export var min_offset: float = 2.0
@export var max_offset: float = 15.0
@export var master_audio_bus: String
@export var music_audio_bus: String
@export var sfx_audio_bus: String


var menu_color = Color("ffffffff")
var is_darker: bool = false
var hovered_button: TextureButton = null
## Bumped on every new shake so any older loop still awaiting can tell it is stale.
var shake_token: int = 0
var rand_offset: Vector2
var this: TextureButton
var z: int = 0
var selected: TextureButton
var element: int
var master_bus_id
var music_bus_id
var sfx_bus_id

func _ready() -> void:
	$Dim.visible = true
	menu.visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	menu_color = Color("ce002fff")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	menu_label.set("theme_override_colors/font_color", menu_color)
	main_buttons.modulate = menu_color
	play_panel.modulate = menu_color
	volume_panel.modulate = menu_color
	settings_panel.modulate = menu_color
	skills_panel.self_modulate = menu_color
	play_panel.visible = true
	volume_panel.visible = false
	settings_panel.visible = false
	skills_panel.visible = false
	selected = play_button
	master_bus_id = AudioServer.get_bus_index("Master")
	music_bus_id = AudioServer.get_bus_index("Music")
	sfx_bus_id = AudioServer.get_bus_index("SFX")


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			menu.visible = false
			get_tree().paused = false
		else:
			menu.visible = true
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if selected != null:
		selected.button_pressed = true


func shaking(element, og_position) -> void:
	shake_token += 1
	var my_token: int = shake_token
	while hovered_button == element and my_token == shake_token:
		rand_offset = Vector2(randf_range(min_offset, max_offset), randf_range(min_offset, max_offset))
		element.position = og_position + rand_offset
		await get_tree().create_timer(0.1).timeout
		element.position = og_position
	element.position = og_position


func stop_shaking(element, og_position) -> void:
	if hovered_button == element:
		hovered_button = null
	element.position = og_position


func visible(element) -> void:
	for i in range(0, panels.get_children().size()):
		panels.get_child(i).visible = false
	panels.get_child(element).visible = true


func _on_settings_button_mouse_entered() -> void:
	hover_sfx.play()
	hovered_button = settings_button
	this = settings_button
	z += 1
	settings_button.z_index = z
	shaking(settings_button, settings_og_position)


func _on_settings_button_mouse_exited() -> void:
	stop_shaking(settings_button, settings_og_position)
	this = null


func _on_volume_button_mouse_entered() -> void:
	hover_sfx.play()
	hovered_button = volume_button
	this = volume_button
	z += 1
	volume_button.z_index = z
	shaking(volume_button, volume_og_position)


func _on_volume_button_mouse_exited() -> void:
	stop_shaking(volume_button, volume_og_position)
	this = null


func _on_play_button_mouse_entered() -> void:
	hover_sfx.play()
	hovered_button = play_button
	this = play_button
	z += 1
	play_button.z_index = z
	shaking(play_button, play_og_position)


func _on_play_button_mouse_exited() -> void:
	stop_shaking(play_button, play_og_position)
	this = null


func _on_skills_button_mouse_entered() -> void:
	hover_sfx.play()
	hovered_button = skills_button
	this = skills_button
	z += 1
	skills_button.z_index = z
	shaking(skills_button, skills_og_position)


func _on_skills_button_mouse_exited() -> void:
	stop_shaking(skills_button, skills_og_position)
	this = null


func _on_play_button_toggled(_toggled_on: bool) -> void:
	select_sfx.play()
	selected = play_button
	element = selected.get_index()
	visible(element)
	menu_label.text = "Menu"


func _on_volume_button_toggled(_toggled_on: bool) -> void:
	select_sfx.play()
	selected = volume_button
	element = selected.get_index()
	visible(element)
	menu_label.text = "Sound Control"


func _on_settings_button_toggled(_toggled_on: bool) -> void:
	select_sfx.play()
	selected = settings_button
	element = selected.get_index()
	visible(element)
	menu_label.text = "Settings"


func _on_skills_button_toggled(toggled_on: bool) -> void:
	select_sfx.play()
	selected = skills_button
	element = selected.get_index()
	visible(element)
	menu_label.text = "Skills"


func _on_exit_button_pressed() -> void:
	back_sfx.play()
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	back_sfx.play()
	$Dim.visible = false
	menu.visible = false
	get_tree().paused = false


func _on_master_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_id, db)


func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_bus_id, db)


func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_bus_id, db)


func _on_color_picker_button_color_changed(color: Color) -> void:
	menu_color = color
	change_color(menu_color)


func change_color(_color) -> void:
	menu_label.set("theme_override_colors/font_color", menu_color)
	main_buttons.modulate = menu_color
	play_panel.modulate = menu_color
	volume_panel.modulate = menu_color
	settings_panel.modulate = menu_color
	skills_panel.self_modulate = menu_color
