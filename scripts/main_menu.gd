
extends Control

@onready var buttons: VBoxContainer = $Buttons
@onready var play_button: Button = $Buttons/PlayButton
@onready var level_select_button: Button = $Buttons/LevelSelectButton
@onready var reset_button: Button = $Buttons/ResetButton
@onready var title: Label = $Title
@onready var level_list: VBoxContainer = $LevelList

const LEVEL_PATHS = [
	"res://scenes/level1.tscn",
	"res://scenes/level2.tscn",
	"res://scenes/level3.tscn",
	"res://scenes/level4.tscn",
	"res://scenes/level5.tscn",
	"res://scenes/level6.tscn",
	"res://scenes/level7.tscn",
	"res://scenes/level8.tscn",
	"res://scenes/level9.tscn"
]

var grid: GridContainer
var back_button: Button
var reset_confirmation: ConfirmationDialog


func _ready() -> void:
	setup_ui()
	show_main_menu()


func setup_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#20252D")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	move_child(background, 0)

	title.text = "🔥 RAGE CORE 🔥"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 55)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title.offset_left = -400
	title.offset_right = 400
	title.offset_top = -280
	title.offset_bottom = -170

	buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	buttons.offset_left = -200
	buttons.offset_right = 200
	buttons.offset_top = -50
	buttons.offset_bottom = 250
	buttons.add_theme_constant_override("separation", 20)

	play_button.text = "PLAY"
	level_select_button.text = "LEVEL SELECT"
	reset_button.text = "RESET ALL STATS"

	style_button(play_button, "#426B45")
	style_button(level_select_button, "#354F70")
	style_button(reset_button, "#873F3F")

	level_list.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	level_list.offset_left = -320
	level_list.offset_right = 320
	level_list.offset_top = -220
	level_list.offset_bottom = 220
	level_list.hide()

	grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	level_list.add_child(grid)

	back_button = Button.new()
	back_button.text = "← BACK"
	back_button.custom_minimum_size = Vector2(180, 55)
	back_button.add_theme_font_size_override("font_size", 24)
	style_button(back_button, "#343A40")
	add_child(back_button)

	back_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	back_button.position = Vector2(30, 30)
	back_button.hide()
	back_button.pressed.connect(show_main_menu)

	reset_confirmation = ConfirmationDialog.new()
	reset_confirmation.title = "Reset All Stats?"
	reset_confirmation.dialog_text = "Are you sure you want to reset all progress?\nAll levels except Level 1 will be locked."
	reset_confirmation.ok_button_text = "Yes, Reset"
	reset_confirmation.cancel_button_text = "Cancel"
	add_child(reset_confirmation)
	reset_confirmation.confirmed.connect(_on_reset_confirmed)

	play_button.pressed.connect(_on_play_pressed)
	level_select_button.pressed.connect(show_level_select)
	reset_button.pressed.connect(_on_reset_pressed)

	create_level_buttons()


func style_button(button: Button, color_hex: String) -> void:
	button.custom_minimum_size = Vector2(400, 75)
	button.add_theme_font_size_override("font_size", 28)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color("#BBBBBB"))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color_hex)
	normal.corner_radius_top_left = 18
	normal.corner_radius_top_right = 18
	normal.corner_radius_bottom_left = 18
	normal.corner_radius_bottom_right = 18

	var hover := normal.duplicate()
	hover.bg_color = Color(color_hex).lightened(0.15)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(color_hex).darkened(0.15)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)


func show_main_menu() -> void:
	title.text = "🔥 RAGE CORE 🔥"
	buttons.show()
	level_list.hide()
	back_button.hide()


func show_level_select() -> void:
	title.text = "LEVEL SELECT"
	buttons.hide()
	level_list.show()
	back_button.show()
	create_level_buttons()


func create_level_buttons() -> void:
	for child in grid.get_children():
		child.queue_free()

	for i in range(LEVEL_PATHS.size()):
		var level_number = i + 1
		var button := Button.new()

		button.custom_minimum_size = Vector2(125, 100)
		button.add_theme_font_size_override("font_size", 30)

		if level_number <= ProgressManager.highest_unlocked_level:
			button.text = str(level_number)
			button.pressed.connect(_on_level_pressed.bind(level_number))
			style_level_button(button, "#426B45")
		else:
			button.text = str(level_number)
			button.disabled = true
			style_level_button(button, "#555B63")

		grid.add_child(button)


func style_level_button(button: Button, color_hex: String) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color_hex)
	normal.corner_radius_top_left = 22
	normal.corner_radius_top_right = 22
	normal.corner_radius_bottom_left = 22
	normal.corner_radius_bottom_right = 22
	normal.border_width_bottom = 5
	normal.border_color = Color(color_hex).darkened(0.25)

	var hover := normal.duplicate()
	hover.bg_color = Color(color_hex).lightened(0.15)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_stylebox_override("disabled", normal)


func _on_play_pressed() -> void:
	var level_number = clamp(ProgressManager.highest_unlocked_level, 1, LEVEL_PATHS.size())
	load_level(level_number)


func _on_level_pressed(level_number: int) -> void:
	load_level(level_number)


func load_level(level_number: int) -> void:
	var path = LEVEL_PATHS[level_number - 1]

	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		push_warning("Level scene not found: " + path)


func _on_reset_pressed() -> void:
	reset_confirmation.popup_centered()


func _on_reset_confirmed() -> void:
	ProgressManager.reset_progress()
	create_level_buttons()
	show_main_menu()
	reset_confirmation.hide()
