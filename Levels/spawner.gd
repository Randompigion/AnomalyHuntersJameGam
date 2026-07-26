extends Node2D
@onready var enemy_template: Node2D = get_node_or_null("../../Entities/Enemy")
@onready var timer: Timer = $Timer

func _ready() -> void:
	if not enemy_template:
		push_error("EnemySpawner: no se encontró 'Enemy' en la ruta esperada. Revisa la ruta relativa.")
		return

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
