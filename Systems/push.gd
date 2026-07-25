class_name Push

static func apply(collision: KinematicCollision2D, impact_velocity: Vector2, force: float) -> void:
	var body := collision.get_collider() as RigidBody2D
	if body == null or body.freeze:
		return
	var offset := collision.get_position() - body.global_position
	var push_dir := -collision.get_normal()
	var impact := (impact_velocity - _velocity_at(body, offset)).dot(push_dir)
	if impact <= 0.0:
		return
	body.apply_impulse(push_dir * impact * body.mass * force, offset)

static func apply_slides(mover: CharacterBody2D, impact_velocity: Vector2, force: float) -> void:
	for i in mover.get_slide_collision_count():
		apply(mover.get_slide_collision(i), impact_velocity, force)

static func spin(mover: CharacterBody2D, impact_velocity: Vector2, force: float, max_spin: float) -> void:
	if mover.get_slide_collision_count() == 0:
		return
	var collision := mover.get_slide_collision(0)
	var body := collision.get_collider() as RigidBody2D
	if body == null or body.freeze or absf(body.angular_velocity) >= max_spin:
		return
	var push_dir := -collision.get_normal()
	var impact := impact_velocity.dot(push_dir)
	if impact <= 0.0:
		return
	var lever := mover.global_position - _center_of_mass(body)
	body.apply_torque_impulse(lever.cross(push_dir * impact * body.mass * force))

static func _velocity_at(body: RigidBody2D, offset: Vector2) -> Vector2:
	var state := PhysicsServer2D.body_get_direct_state(body.get_rid())
	if state == null:
		return body.linear_velocity
	return state.get_velocity_at_local_position(offset)

static func _center_of_mass(body: RigidBody2D) -> Vector2:
	var state := PhysicsServer2D.body_get_direct_state(body.get_rid())
	if state == null:
		return body.global_position
	return body.global_position + state.center_of_mass
