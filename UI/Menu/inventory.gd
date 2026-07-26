extends Resource

class_name Inventory

signal updated

const OVERPOWERED_SKILLS: Array[String] = ["DashUnlimited", "LimiterOff", "AbilityMaximum"]

const OVERPOWERED_SKILL_PATHS: Array[String] = [
	"res://UI/Menu/Skills/DashUnlimited.tres",
	"res://UI/Menu/Skills/LimiterOff.tres",
	"res://UI/Menu/Skills/AbilitiyMaximum.tres",
]

@export var items: Array[InventoryItem]

var overpoweredUnlocked = null

var storedItems: Array[InventoryItem] = []

func setOverpoweredUnlocked(unlocked: bool):
	if unlocked == overpoweredUnlocked: return
	overpoweredUnlocked = unlocked

	if unlocked:
		equipOverpoweredLoadout()
	else:
		restoreStoredItems()
		hideOverpowered()

	updated.emit()

func equipOverpoweredLoadout():
	if storedItems.is_empty():
		storedItems = items.duplicate()

	for i in range(items.size()):
		items[i] = load(OVERPOWERED_SKILL_PATHS[i]) if i < OVERPOWERED_SKILL_PATHS.size() else null

func restoreStoredItems():
	if storedItems.is_empty(): return
	items = storedItems.duplicate()
	storedItems.clear()

func hideOverpowered():
	for i in range(items.size()):
		var item: InventoryItem = items[i]
		if item and item.name in OVERPOWERED_SKILLS:
			items[i] = null

func removeSlot(inventoryItem: InventoryItem):
	var index = items.find(inventoryItem)
	if index < 0: return
	items[index] = InventoryItem.new()
	updated.emit()
	
func insertItem(index: int, inventoryItem: InventoryItem):
	
	
	items[index] = inventoryItem
	updated.emit()
