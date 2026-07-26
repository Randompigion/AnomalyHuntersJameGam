extends Button

const ACTIVE_COLOR := Color(1, 1, 1, 1)
const COOLDOWN_COLOR := Color(0.6, 0.6, 0.6, 1)
const ICON_READY := Color(1, 1, 1, 1)
const ICON_COOLDOWN := Color(0.4, 0.4, 0.4, 1)

@onready var background_sprite: Sprite2D = $background
@onready var item_stack_gui: ItemsGUI = $CenterContainer/Panel
@onready var status_label: Label = $StatusLabel

var skill_name: String = ""

func update_to_slot(slot: InventoryItem) -> void:
	if !slot:
		item_stack_gui.visible = false
		skill_name = ""
		status_label.text = ""
		return

	skill_name = slot.name
	item_stack_gui.inventoryItem = slot
	item_stack_gui.update()
	item_stack_gui.visible = true

func update_status(player: Node) -> void:
	if skill_name == "" or not player.has_method("get_skill_status"):
		status_label.text = ""
		return

	var status: Dictionary = player.get_skill_status(skill_name)
	match status["state"]:
		"active":
			status_label.text = "ON " + _format_seconds(status["value"])
			status_label.modulate = ACTIVE_COLOR
			_set_icon_dimmed(false)
		"charges":
			status_label.text = "USE %d" % status["value"]
			status_label.modulate = ACTIVE_COLOR
			_set_icon_dimmed(false)
		"cooldown":
			status_label.text = "CD " + _format_seconds(status["value"])
			status_label.modulate = COOLDOWN_COLOR
			_set_icon_dimmed(true)
		_:
			status_label.text = ""
			_set_icon_dimmed(false)

func _format_seconds(seconds: float) -> String:
	if seconds >= 9.95:
		return "%d" % ceili(seconds)
	return "%.1f" % seconds

func _set_icon_dimmed(dimmed: bool) -> void:
	var tint: Color = ICON_COOLDOWN if dimmed else ICON_READY
	background_sprite.modulate = tint
	item_stack_gui.modulate = tint
