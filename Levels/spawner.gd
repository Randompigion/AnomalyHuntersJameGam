extends Node2D

@onready var enemy_template: Node2D = $"../../Enemy"
@onready var timer: Timer = $Timer

func _ready() -> void:
	enemy_template.visible = false
	enemy_template.set_process(false)
	enemy_template.set_physics_process(false)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_template:
		return
	
	var enemy_clone = enemy_template.duplicate()
	
	enemy_clone.global_position = global_position
	
	get_tree().current_scene.add_child(enemy_clone)
	
	enemy_clone.visible = true
	enemy_clone.set_process(true)
	enemy_clone.set_physics_process(true)
