extends Control

@onready var inventory : Inventory = preload("res://UI/Menu/playerInventory.tres")
@onready var ItemGuiClass = preload("res://UI/Menu/items_gui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var itemInHand: ItemsGUI

func _ready() -> void:
	connect_slots()
	update()
	
func connect_slots():
	for i in range(slots.size()):
		var slot = slots[i] 
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		var inventoryItem: InventoryItem = inventory.items[i]
		
		if !inventoryItem: continue
		
		var itemGui: ItemsGUI = slots[i].itemGui
		if !itemGui:
			itemGui = ItemGuiClass.instantiate()
			slots[i].insert(itemGui)
			
		itemGui.inventoryItem = inventoryItem
		itemGui.update()
			
		
func onSlotClicked(slot):
	if slot.isEmpty():
		if !itemInHand: return
		
		insertItemInSlot(slot)
		return
		
	if !itemInHand:
		takeItemFromSlot(slot)
		return
		
	swapItems(slot)
	
func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	
func insertItemInSlot(slot):
	var item = itemInHand
	
	remove_child(itemInHand)
	itemInHand = null
	
	slot.insert(item)
	
func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2
	
func _input(event: InputEvent):
	updateItemInHand()	
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()
