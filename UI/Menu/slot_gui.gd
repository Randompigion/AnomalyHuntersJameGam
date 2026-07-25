extends Button

@onready var backgroundSprite: Sprite2D = $background
@onready var container: CenterContainer = $CenterContainer

@onready var inventory = preload("res://UI/Menu/playerInventory.tres")

var itemGui: ItemsGUI
var index: int

func insert(isg: ItemsGUI):
	itemGui = isg
	container.add_child(itemGui)
	# TEMP: keep the name tooltip in sync when skills are dragged around.
	tooltip_text = isg.inventoryItem.name if isg.inventoryItem else ""
	if !itemGui.inventoryItem || inventory.items[index] == itemGui.inventoryItem:
		return
	
	inventory.insertItem(index, itemGui.inventoryItem)
	
func takeItem():
	var item = itemGui

	# TEMP: slot is about to be empty, so drop its name tooltip.
	tooltip_text = ""

	inventory.removeSlot(itemGui.inventoryItem)
	
	container.remove_child(itemGui)
	itemGui = null
	
	return item
	
func isEmpty():
	return !itemGui
		
		
