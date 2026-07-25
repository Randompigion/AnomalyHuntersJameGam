extends Resource

class_name Inventory

signal updated

@export var items: Array[InventoryItem]

func removeSlot(inventoryItem: InventoryItem):
	var index = items.find(inventoryItem)
	if index < 0: return
	items[index] = InventoryItem.new()
	updated.emit()
	
func insertItem(index: int, inventoryItem: InventoryItem):
	
	
	items[index] = inventoryItem
	updated.emit()
