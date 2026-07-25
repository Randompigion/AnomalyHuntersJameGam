extends CharacterBody2D

@export var inventory: Inventory



@export var speed = 750.0
@export var dash_speed = 1050
@export var friction = 200
@export var bounce_speed_retention = 0.6
@export var stun_duration = 1.5
@export var heavy_stun_duration = 3.0
@export var max_hp: int = 3

@export var chain_kill_dashes = 5
@export var chain_kill_targets = 2
@export var chain_kill_dash_speed = 750
@export var chain_kill_time_cost = 5
@export var chain_kill_restore_ratio = 0.3

@export var bounce_lock_duration = 0.2
@export var bounce_push_force: float = 2.0
@export var bounce_spin_force: float = 0.08
@export var bounce_max_spin: float = 6.0
var hp: int = max_hp
var is_invincible: bool = false
var dashing = false
var direction: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var can_move = true
var can_dash = true
var can_toggle = true
var can_speed_boost = true
var can_poly_spike = true
var can_stun_save = true
var stun_save_active = false
var can_chain_kill = true
var chain_kill_charges = 0
var chain_dash_active = false
var chain_kill_prev_dash_speed = 1050
var bounce_lock = false
enum Mode { DASH, BOUNCE, SPIKEY }
var mode: Mode = Mode.DASH

@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var stun_timer: Timer = $stunt_timer
@onready var bounce_sound: AudioStreamPlayer2D = $BounceSound
const STUN_SOUNDS := [
	preload("res://Assets/Audio/SFX/Player/sfx_player_damaged.wav"),
	preload("res://Assets/Audio/SFX/Player/sfx_player_stunned.wav"),
]

func _ready() -> void:
	add_to_group("player")
	hp = max_hp
	stun_timer.one_shot = true
	if not stun_timer.timeout.is_connected(_on_stun_timer_timeout):
		stun_timer.timeout.connect(_on_stun_timer_timeout)
	dir = (get_global_mouse_position() - global_position).normalized()

var dir = Vector2.ZERO
var input = "a"

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if mode == Mode.DASH:
		if not dashing:
			if dir != Vector2.ZERO:
				rotation = dir.angle()
	else:
		if not bounce_lock:
			if dir != Vector2.ZERO:
				rotation = lerp_angle(rotation, dir.angle(), 20 * delta)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var controller_dir := Input.get_vector("left", "right", "up", "down")
	if controller_dir != Vector2.ZERO and (input == "a" or input == "c"):
		dir = controller_dir
	elif input == "a" or input == "m":
		dir = (get_global_mouse_position() - global_position).normalized()
	if Input.is_action_just_pressed("dash") and can_dash and can_move:
		dashing = true
		dash_direction = dir
		rotation = dash_direction.angle()
		$AudioStreamPlayer2D.play()
		can_dash = false
		$dash_timer.start()
		$dash_cooldown.start()
		if chain_kill_charges > 0:
			_spend_chain_kill_dash()

	if Input.is_action_just_pressed("toggle_mode"):
		_toggle_mode()

	if can_move:
		if dashing:
			velocity = dash_speed * dash_direction
		elif bounce_lock:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		else:
			if Input.is_action_pressed("propel"):
				velocity = speed * dir
			else:
				velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	else:
		velocity = Vector2.ZERO

	if dashing and mode == Mode.BOUNCE:
		var collision := move_and_collide(velocity * delta)
		if collision:
			Push.apply(collision, velocity, bounce_push_force)
			velocity = velocity.bounce(collision.get_normal()) * bounce_speed_retention
			dash_direction = velocity.normalized()
			rotation = dash_direction.angle()
			dashing = false
			bounce_lock = true
			$%Effects.play("Bounce")
			_play_bounce()
			get_tree().create_timer(bounce_lock_duration).timeout.connect(func(): bounce_lock = false)
	else:
		var impact_velocity := velocity
		move_and_slide()
		if mode == Mode.BOUNCE:
			Push.spin(self, impact_velocity, bounce_spin_force, bounce_max_spin)
		_handle_wall_collisions()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("skill_1"): use_skill(0)
	if Input.is_action_just_pressed("skill_2"): use_skill(1)
	if Input.is_action_just_pressed("skill_3"): use_skill(2)

func use_skill(index: int) -> void:
	if index >= inventory.items.size(): return
	var item: InventoryItem = inventory.items[index]
	if !item or item.name == "": return

	match item.name:
		"BlastDash":       blast_dash()
		"PolySpikes":      poly_spikes()
		"SpeedBoost":      speed_boost()
		"BlinkDash":       blink_dash()
		"ChainKill":       chain_kill()
		"GotYourBack":     got_your_back()
		"SlideBounce":     slide_bounce()
		"StunSave":        stun_save()
		"TemporalTargets": temporal_targets()
		_: push_warning("No ability hooked up for: %s" % item.name)

func blast_dash():
	print("blast dash!")

func poly_spikes():
	if mode == Mode.DASH:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("spikeydash"):
				sprite.play("spikeydash")
	if mode == Mode.BOUNCE:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("spikeybounce"):
				sprite.play("spikeybounce")
	sprite.scale = Vector2(1.55, 1.55)
	mode = Mode.SPIKEY
	can_dash = false
	can_toggle = false
	speed = 550
	$AbilityTimers/ActivationTime/PolySpikes.start()
	can_poly_spike = false
	$AbilityTimers/Cooldowns/PolySpikesCooldown.start()
	
	
func speed_boost():
	if can_speed_boost:
		speed = 1250
		dash_speed = 1550
		bounce_speed_retention = 1.5
		can_speed_boost = false
		print("huzzaf")
		$AbilityTimers/ActivationTime/SpeedBoost.start()
		$AbilityTimers/Cooldowns/SpeedBoostCooldown.start()
		
func blink_dash():
	print("blink dash!")
	
func chain_kill():
	if can_chain_kill:
		can_chain_kill = false
		chain_kill_charges = chain_kill_dashes
		chain_kill_prev_dash_speed = dash_speed
		dash_speed = chain_kill_dash_speed
		$AbilityTimers/Cooldowns/ChainKillCooldown.start()
	
func got_your_back():
	print("got your back!")
	
func slide_bounce():
	print("slide bounce!")
	
func stun_save():
	if can_stun_save:
		stun_save_active = true
		can_stun_save = false
		$AbilityTimers/ActivationTime/StunSave.start()
		$AbilityTimers/Cooldowns/StunSaveCooldown.start()
	
func temporal_targets():
	print("temporal targets!")

func _toggle_mode() -> void:
	if can_toggle:
		if mode == Mode.DASH:
			mode = Mode.BOUNCE
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("bounce"):
				sprite.play("bounce")
		else:
			mode = Mode.DASH
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("dash"):
				sprite.play("dash")

func _handle_wall_collisions() -> void:
	if not dashing:
		return
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		var normal := collision.get_normal()

		if collider and collider.is_in_group("boss"):
			if mode == Mode.DASH:
				var hit_angle: float = (global_position - collider.global_position).angle()
				var hit_confirmed: bool = collider.try_hit_weak_point(hit_angle)
				if not hit_confirmed:
					dashing = false
					velocity = Vector2.ZERO
					take_damage(1)
			else:
				velocity = velocity.bounce(normal) * bounce_speed_retention
				dash_direction = velocity.normalized()
				rotation = dash_direction.angle()
				_play_bounce()
			break

		if collider and collider.is_in_group("spiky_enemy"):
			if mode == Mode.DASH:
				dashing = false
				velocity = Vector2.ZERO
				_apply_heavy_stun()
			else:
				velocity = velocity.bounce(normal) * bounce_speed_retention
				dash_direction = velocity.normalized()
				rotation = dash_direction.angle()
				_play_bounce()
			break

		if collider and collider.is_in_group("enemy"):
			if mode == Mode.DASH:
				_kill_enemy(collider)
			continue

		if mode == Mode.BOUNCE:
			velocity = velocity.bounce(normal) * bounce_speed_retention
			dash_direction = velocity.normalized()
			rotation = dash_direction.angle()
			_play_bounce()
		else:
			dashing = false
			velocity = Vector2.ZERO
			take_damage(1)
		break

func _play_bounce() -> void:
	if bounce_sound.stream:
		$Camera2D2.trigger_shake()
		bounce_sound.play()

func _kill_enemy(enemy: Node) -> void:
	%Effects.play("Kill")
	var origin: Vector2 = enemy.global_position
	if enemy.has_method("die"):
		enemy.die()
	else:
		enemy.queue_free()
	if chain_dash_active:
		_chain_slash_nearest(enemy, origin)

func _spend_chain_kill_dash() -> void:
	chain_kill_charges -= 1
	chain_dash_active = true
	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.subtract_time(chain_kill_time_cost)

func _end_chain_dash() -> void:
	chain_dash_active = false
	if chain_kill_charges <= 0:
		dash_speed = chain_kill_prev_dash_speed

func _chain_slash_nearest(source: Node, origin: Vector2) -> void:
	var others: Array = []
	for e in get_tree().get_nodes_in_group("enemy"):
		if e == source or not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		others.append(e)
	others.sort_custom(func(a, b):
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))

	var time_left = get_tree().get_first_node_in_group("time_left")
	for i in range(min(chain_kill_targets, others.size())):
		var target = others[i]
		var before: float = time_left.time_left if time_left else 0.0
		%Effects.play("Kill")
		if target.has_method("die"):
			target.die()
		else:
			target.queue_free()
		if time_left:
			var gained: float = time_left.time_left - before
			if gained > 0.0:
				time_left.time_left = before + gained * chain_kill_restore_ratio

func take_damage(amount: int) -> void:
	if is_invincible:
		return

	dashing = false
	velocity = Vector2.ZERO
	_apply_stun()
	$Camera2D2.trigger_shake()
	Sfx.play(STUN_SOUNDS.pick_random())

	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.subtract_time(amount * 10)

	is_invincible = true
	sprite.modulate.a = 0.5
	await get_tree().create_timer(1.0).timeout
	sprite.modulate.a = 1.0
	is_invincible = false

func _apply_stun() -> void:
	if stun_save_active:
		_stun_save_penalty()
		return
	can_move = false
	stun_timer.stop()
	stun_timer.start(stun_duration)

func _apply_heavy_stun() -> void:
	if stun_save_active:
		_stun_save_penalty()
		return
	can_move = false
	stun_timer.stop()
	stun_timer.start(heavy_stun_duration)

func _stun_save_penalty() -> void:
	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.subtract_time(10)

func _on_stun_timer_timeout() -> void:
	can_move = true

func _on_dash_timer_timeout() -> void:
	dashing = false
	if chain_dash_active:
		_end_chain_dash()

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func hazard_kill() -> void:
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	dashing = false


func _on_speed_boost_timeout() -> void:
	speed = 750
	dash_speed = 1050
	bounce_speed_retention = 0.6
	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.subtract_time(20)
	

func _on_poly_spikes_timeout() -> void:
	sprite.play("dash")
	sprite.scale = Vector2(0.3, 0.3)
	mode = Mode.DASH
	can_dash = true
	can_toggle = true
	speed = 550
	var time_left = get_tree().get_first_node_in_group("time_left")
	if time_left:
		time_left.subtract_time(35)

func _on_speed_boost_cooldown_timeout() -> void:
	can_speed_boost = true


func _on_poly_spikes_cooldown_timeout() -> void:
	can_poly_spike = true


func _on_stun_save_timeout() -> void:
	stun_save_active = false


func _on_stun_save_cooldown_timeout() -> void:
	can_stun_save = true


func _on_chain_kill_cooldown_timeout() -> void:
	can_chain_kill = true
