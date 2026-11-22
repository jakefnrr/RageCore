
extends Control

@onready var background: ColorRect = $Background
@onready var ending_title: Label = $EndingTitle
@onready var play_again_button: Button = $PlayAgainButton

const TOTAL_LEVELS := 8
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"

var flash_timer := 0.0
var flash_index := 0

var flash_colors: Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.WHITE
]


func _ready() -> void:
	# Background
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color.BLACK
	background.z_index = -1

	# Title
	ending_title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ending_title.add_theme_font_size_override("font_size", 100)

	# Button
	play_again_button.text = "PLAY AGAIN"
	play_again_button.add_theme_font_size_override("font_size", 32)
	play_again_button.anchor_left = 0.30
	play_again_button.anchor_right = 0.70
	play_again_button.anchor_top = 0.70
	play_again_button.anchor_bottom = 0.82
	play_again_button.pressed.connect(_on_play_again_pressed)

	# Check every regular apple from levels 1 to 8
	var all_apples_collected := true

	for level in range(1, TOTAL_LEVELS + 1):
		if not ProgressManager.has_collected_apple(level):
			all_apples_collected = false
			break

	if all_apples_collected:
		show_win_screen()
	else:
		show_lose_screen()


func show_win_screen() -> void:
	ending_title.text = "YOU WIN!!!"
	play_again_button.visible = false

	create_confetti()

	# Return to menu after 2 seconds
	await get_tree().create_timer(2.0).timeout

	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func show_lose_screen() -> void:
	ending_title.text = "YOU LOSE!"
	play_again_button.visible = true


func create_confetti() -> void:
	var confetti := CPUParticles2D.new()

	confetti.name = "Confetti"
	confetti.position = Vector2(
		get_viewport_rect().size.x / 2,
		-20
	)

	confetti.emitting = false
	confetti.one_shot = true
	confetti.amount = 150
	confetti.lifetime = 2.0
	confetti.explosiveness = 0.0
	confetti.direction = Vector2(0, 1)
	confetti.spread = 35.0
	confetti.gravity = Vector2(0, 180)
	confetti.initial_velocity_min = 100.0
	confetti.initial_velocity_max = 250.0
	confetti.scale_amount_min = 3.0
	confetti.scale_amount_max = 7.0
	confetti.color = Color.GOLD

	confetti.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	confetti.emission_rect_extents = Vector2(
		get_viewport_rect().size.x / 2,
		10
	)

	add_child(confetti)
	confetti.z_index = 10
	confetti.emitting = true


func _process(delta: float) -> void:
	flash_timer += delta

	if flash_timer >= 0.1:
		flash_timer = 0.0
		flash_index = (flash_index + 1) % flash_colors.size()

		ending_title.add_theme_color_override(
			"font_color",
			flash_colors[flash_index]
		)


func _on_play_again_pressed() -> void:
	ProgressManager.reset_progress()
	get_tree().change_scene_to_file("res://scenes/level1.tscn")
