extends Control

@onready var main_buttons: Control = $MainButtons
@onready var menu_label: Label = $MenuLabel
@onready var play_panel: Panel = $PlayPanel
@onready var volume_panel: Panel = $VolumePanel
@onready var settings_panel: Panel = $SettingsPanel
@onready var settings_button: TextureButton = $MainButtons/SettingsButton
@onready var volume_button: TextureButton = $MainButtons/VolumeButton
@onready var play_button: TextureButton = $MainButtons/PlayButton
@onready var settings_og_position: Vector2 = settings_button.position
@onready var volume_og_position: Vector2 = volume_button.position
@onready var play_og_position: Vector2 = play_button.position

@export var shake: float = 4.0
@export var min_offset: float = 2.0
@export var max_offset: float = 15.0


var menu_color = Color(0.809, 0.0, 0.186)
var is_darker: bool = false
var is_hovering: bool = false
var rand_offset: Vector2
var this: TextureButton
var z: int = 0
var selected: TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.modulate = menu_color
	play_panel.modulate = menu_color
	play_panel.visible = true
	volume_panel.visible = false
	settings_panel.visible = false
	selected = play_button
	menu_label.add_theme_color_override("font_color", menu_color.darkened(0.3))


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


func _on_play_button_toggled(_toggled_on: bool) -> void:
	selected = play_button


func _on_volume_button_toggled(_toggled_on: bool) -> void:
	selected = volume_button


func _on_settings_button_toggled(_toggled_on: bool) -> void:
	selected = settings_button
