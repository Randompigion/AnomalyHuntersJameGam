extends CharacterBody2D
var player
var direction
const SPEED = 50

func _ready() -> void:
	player = $"../Triangle"

#I set the enemies up so they can only be able to sense the player, and just check if it enters and kills itself.
#We might want to replace this, but it should allow us to quickly test.
func _on_kill_zone_body_entered(body: Node2D) -> void:
	queue_free()

#The player calls this signal, however it doesn't call it yet. Maybe we can do on body enter check if has this?
func die():
	#Put animation here when done!
	queue_free()

#walk to player
func _physics_process(delta: float) -> void:
	direction = (player.global_position - position).normalized
	#I'm too tired to figure this out, but basically it needs to do this equation and itll work.
#	velocity = (direction * SPEED) * delta
	move_and_slide()
