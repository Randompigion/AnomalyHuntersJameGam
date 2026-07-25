class_name Push

static func apply(collision: KinematicCollision2D, impact_velocity: Vector2, force: float) -> void:
	var body := collision.get_collider() as RigidBody2D
	if body == null or body.freeze:
		return
	var push_dir := -collision.get_normal()
	var impact := (impact_velocity - body.linear_velocity).dot(push_dir)
	if impact <= 0.0:
		return
	var impulse := push_dir * impact * body.mass * force
	body.apply_impulse(impulse, collision.get_position() - body.global_position)

static func apply_slides(mover: CharacterBody2D, impact_velocity: Vector2, force: float) -> void:
	for i in mover.get_slide_collision_count():
		apply(mover.get_slide_collision(i), impact_velocity, force)
