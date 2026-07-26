extends HBoxContainer

@onready var inventory: Inventory = preload("res://UI/Menu/playerInventory.tres")
@onready var slots: Array = get_children()

var player: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for slot in slots:
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.focus_mode = Control.FOCUS_NONE
	update()
	inventory.updated.connect(update)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InventoryItem = inventory.items[i]
		slots[i].update_to_slot(inventory_slot)

func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	for slot in slots:
		slot.update_status(player)
