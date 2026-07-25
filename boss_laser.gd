extends Node2D

signal finished

@export var telegraph_duration: float = 1.2
@export var active_duration: float = 0.3
@export var length: float = 2000.0
@export var width: float = 18.0
@export var telegraph_color: Color = Color(1.0, 0.2, 0.2, 0.25)
@export var active_color: Color = Color(1.0, 0.1, 0.1, 1.0)

var direction: Vector2 = Vector2.RIGHT
var origin_node: Node2D
var player: Node2D

@onready var line: Line2D = $Line2D


func setup(from: Node2D, aim_direction: Vector2, target_player: Node2D) -> void:
	origin_node = from
	direction = aim_direction.normalized()
	player = target_player
	global_position = from.global_position
	rotation = direction.angle()


func fire() -> void:
	line.width = width * 0.3
	line.default_color = telegraph_color
	line.points = [Vector2.ZERO, Vector2.RIGHT * length]
	line.visible = true

	var elapsed: float = 0.0
	while elapsed < telegraph_duration:
		var t: float = elapsed / telegraph_duration
		line.width = lerp(width * 0.2, width * 0.7, t)
		line.default_color.a = lerp(0.15, 0.6, t)
		elapsed += get_process_delta_time()
		await get_tree().process_frame

	line.width = width
	line.default_color = active_color
	_check_hit()

	await get_tree().create_timer(active_duration).timeout

	finished.emit()
	queue_free()


func _check_hit() -> void:
	if not player:
		return

	var space_state := get_world_2d().direct_space_state
	var shape := RectangleShape2D.new()
	shape.size = Vector2(length, width)

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(rotation, global_position + Vector2.RIGHT.rotated(rotation) * (length * 0.5))
	query.collide_with_bodies = true
	query.collide_with_areas = false
	if origin_node:
		query.exclude = [origin_node.get_rid()]

	var results := space_state.intersect_shape(query)
	for result in results:
		var collider = result.collider
		if collider != player:
			continue

		var boss_vulnerable: bool = origin_node and origin_node.get("is_vulnerable")

		if boss_vulnerable:
			if player.has_method("apply_vulnerable_knockback"):
				var away_dir: Vector2 = (player.global_position - origin_node.global_position).normalized()
				player.apply_vulnerable_knockback(away_dir)
		elif player.has_method("take_damage"):
			player.take_damage(1)
