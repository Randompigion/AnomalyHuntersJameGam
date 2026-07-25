extends Panel

class_name ItemsGUI

@onready var itemSprite: Sprite2D = $item

var inventoryItem: InventoryItem
func update():
	if !inventoryItem: return
	
	itemSprite.visible = true
	itemSprite.texture = inventoryItem.texture
