
extends Node

const SAVE_PATH = "user://progress.cfg"

var highest_unlocked_level: int = 1
var collected_apples: Array[int] = []
var held_touch_positions: Dictionary = {}


func _ready() -> void:
	load_progress()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			held_touch_positions[event.index] = event.position
		else:
			held_touch_positions.erase(event.index)


func load_progress() -> void:
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		highest_unlocked_level = int(config.get_value("progress", "highest_level", 1))

		var saved_apples = config.get_value("progress", "collected_apples", [])
		collected_apples.clear()

		for apple_level in saved_apples:
			collected_apples.append(int(apple_level))
	else:
		highest_unlocked_level = 1
		collected_apples.clear()


func save_progress() -> void:
	var config = ConfigFile.new()
	config.set_value("progress", "highest_level", highest_unlocked_level)
	config.set_value("progress", "collected_apples", collected_apples)
	config.save(SAVE_PATH)


func unlock_level(level_number: int) -> void:
	if level_number > highest_unlocked_level and level_number <= 9:
		highest_unlocked_level = level_number
		save_progress()


func collect_apple(level_number: int) -> void:
	if not collected_apples.has(level_number):
		collected_apples.append(level_number)
		save_progress()


func has_collected_apple(level_number: int) -> bool:
	return collected_apples.has(level_number)


func reset_progress() -> void:
	highest_unlocked_level = 1
	collected_apples.clear()
	save_progress()
