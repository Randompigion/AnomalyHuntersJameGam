extends Area2D



func _on_body_entered(body: Node2D) -> void:
	print("it should work?")
	$CircleDialouge.visible = true
	$CircleDialouge.start()
	
