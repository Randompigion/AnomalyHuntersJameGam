extends Control

@onready var panels: Control = $Panels
@onready var main_buttons: Control = $MainButtons
@onready var menu_label: Label = $MenuLabel
@onready var play_panel: Panel = $Panels/PlayPanel
@onready var volume_panel: Panel = $Panels/VolumePanel
@onready var settings_panel: Panel = $Panels/SettingsPanel
@onready var skills_panel: Panel = $Panels/SkillsPanel
@onready var settings_button: TextureButton = $MainButtons/SettingsButton
@onready var volume_button: TextureButton = $MainButtons/VolumeButton
@onready var play_button: TextureButton = $MainButtons/PlayButton
@onready var skills_button: TextureButton = $MainButtons/SkillsButton
@onready var settings_og_position: Vector2 = settings_button.position
@onready var volume_og_position: Vector2 = volume_button.position
@onready var play_og_position: Vector2 = play_button.position
@onready var skills_og_position: Vector2 = skills_button.position

@export var shake: float = 4.0
@export var min_offset: float = 2.0
@export var max_offset: float = 15.0
@export var master_audio_bus: String
@export var music_audio_bus: String
@export var sfx_audio_bus: String

var menu_color = Color(0.809, 0.0, 0.186)
var is_darker: bool = false
var is_hovering: bool = false
var rand_offset: Vector2
var this: TextureButton
var z: int = 0
var selected: TextureButton
var element: int
var master_bus_id
var music_bus_id
var sfx_bus_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	main_buttons.modulate = menu_color
	panels.modulate = menu_color
	play_panel.visible = true
	volume_panel.visible = false
	settings_panel.visible = false
	skills_panel.visible = false
	selected = play_button
	master_bus_id = AudioServer.get_bus_index("Master")
	music_bus_id = AudioServer.get_bus_index('Music')
	sfx_bus_id = AudioServer.get_bus_index("SFX")
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if selected != null:
		selected.button_pressed = true


func shaking(element, og_position) -> void:
	while is_hovering == true:
		rand_offset = Vector2(randf_range(min_offset, max_offset), randf_range(min_offset, max_offset))
		element.position += rand_offset
		await get_tree().create_timer(0.1).timeout
		element.position = og_position


func visible(element) -> void:
	for i in range(0, panels.get_children().size()):
		panels.get_child(i).visible = false
	panels.get_child(element).visible = true


func _on_settings_button_mouse_entered() -> void:
	is_hovering = true
	this = settings_button
	shaking(this, settings_og_position)
	z += 1
	settings_button.z_index = z


func _on_settings_button_mouse_exited() -> void:
	is_hovering = false
	this = null


func _on_volume_button_mouse_entered() -> void:
	is_hovering = true
	this = volume_button
	shaking(this, volume_og_position)
	z += 1
	volume_button.z_index = z


func _on_volume_button_mouse_exited() -> void:
	is_hovering = false
	this = null


func _on_play_button_mouse_entered() -> void:
	is_hovering = true
	this = play_button
	shaking(this, play_og_position)
	z += 1
	play_button.z_index = z


func _on_play_button_mouse_exited() -> void:
	is_hovering = false
	this = null


func _on_skills_button_mouse_entered() -> void:
	is_hovering = true
	this = skills_button
	shaking(this, skills_og_position)
	z += 1
	skills_button.z_index = z


func _on_skills_button_mouse_exited() -> void:
	is_hovering = false
	this = null


func _on_play_button_toggled(_toggled_on: bool) -> void:
	selected = play_button
	element = selected.get_index()
	visible(element)


func _on_volume_button_toggled(_toggled_on: bool) -> void:
	selected = volume_button
	element = selected.get_index()
	visible(element)


func _on_settings_button_toggled(_toggled_on: bool) -> void:
	selected = settings_button
	element = selected.get_index()
	visible(element)


func _on_skills_button_toggled(toggled_on: bool) -> void:
	selected = skills_button
	element = selected.get_index()
	visible(element)


func _on_resume_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/TutorialLevel.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_master_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_id, db)


func _on_sfx_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfx_bus_id, db)


func _on_music_slider_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(music_bus_id, db)
