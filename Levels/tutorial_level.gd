extends Node2D

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$AudioTriggers/Narrator1.play()
	await $AudioTriggers/Narrator1.finished
	$AudioTriggers/Narrator2.play()
	await $AudioTriggers/Narrator2.finished
	$AudioTriggers/Narrator3.play()
	await $AudioTriggers/Narrator3.finished


func _on_narrator_4_trigger_body_entered(body: Node2D) -> void:
	await $AudioTriggers/Narrator3.finished
	$AudioTriggers/Narrator4.play()


func _on_narrator_5_trigger_body_entered(body: Node2D) -> void:
	await $AudioTriggers/Narrator4.finished
	$AudioTriggers/Narrator5.play()


func _on_narrator_6_trigger_body_entered(body: Node2D) -> void:
	$AudioTriggers/Narrator6.play()
