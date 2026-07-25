extends HBoxContainer

@onready var inventory: Inventory = preload("res://UI/Menu/playerInventory.tres")
@onready var slots: Array = get_children()

func _ready() -> void:
	update()
	inventory.updated.connect(update)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InventoryItem = inventory.items[i]
		slots[i].update_to_slot(inventory_slot)
