extends Sprite2D

const portal_sound = preload("res://Assets/Audio/SFX/System/portal.mp3")

@export var volume_db: float = 0.0


func _ready() -> void:
	var area := Area2D.new()
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = _sprite_size()
	collision.shape = box
	collision.position = offset if centered else offset + box.size * 0.5
	area.add_child(collision)
	add_child(area)
	area.body_entered.connect(_on_body_entered)


func _sprite_size() -> Vector2:
	if texture == null:
		return Vector2(64, 64)
	if region_enabled:
		return region_rect.size
	return texture.get_size() / Vector2(hframes, vframes)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Sfx.play(portal_sound, volume_db)
