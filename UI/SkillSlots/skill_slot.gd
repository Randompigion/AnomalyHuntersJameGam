extends Button

@onready var background_sprite: Sprite2D = $background
@onready var item_stack_gui: ItemsGUI = $CenterContainer/Panel

func update_to_slot(slot: InventoryItem) -> void:
	if !slot:
		item_stack_gui.visible = false
		return
	
	item_stack_gui.inventoryItem = slot
	item_stack_gui.update()
	item_stack_gui.visible = true
