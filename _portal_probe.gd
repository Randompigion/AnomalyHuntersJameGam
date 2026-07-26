extends SceneTree

var frames := 0
var inst: Node
var portal: Node
var tri: Node2D

func _initialize() -> void:
	var scene := load("res://Levels/forest_level.tscn")
	print("PROBE loaded scene: ", scene)
	inst = scene.instantiate()
	root.add_child(inst)
	current_scene = inst
	portal = inst.get_node_or_null("PortalToBoss")
	print("PROBE portal: ", portal)
	print("PROBE portal script: ", portal.get_script())
	for c in portal.get_children():
		print("PROBE child: ", c.name, " class=", c.get_class())
		if c is Area2D:
			print("PROBE   mask=", c.collision_mask, " monitoring=", c.monitoring)
			print("PROBE   conns=", c.get_signal_connection_list("body_entered"))
	tri = inst.get_node_or_null("Entities/Triangle")
	print("PROBE triangle: ", tri, " layer=", tri.collision_layer, " mask=", tri.collision_mask)
	tri.global_position = portal.global_position

func _process(_d: float) -> bool:
	frames += 1
	if tri and is_instance_valid(tri):
		tri.global_position = portal.global_position
	if frames == 30:
		print("PROBE current_scene after 30 frames: ", current_scene, " file=", current_scene.scene_file_path if current_scene else "null")
		return true
	return false
