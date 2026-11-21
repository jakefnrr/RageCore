
extends Control

@onready var background: ColorRect = $Background
@onready var ending_title: Label = $EndingTitle
@onready var play_again_button: Button = $PlayAgainButton

var flash_timer: float = 0.0
var flash_index: int = 0

var flash_colors: Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.WHITE
]


func _ready() -> void:
	# Background
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color.BLACK

	# Centered massive title
	ending_title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ending_title.add_theme_font_size_override("font_size", 100)

	# Play Again button underneath
	play_again_button.anchor_left = 0.30
	play_again_button.anchor_right = 0.70
	play_again_button.anchor_top = 0.70
	play_again_button.anchor_bottom = 0.82
	play_again_button.add_theme_font_size_override("font_size", 32)
	play_again_button.text = "PLAY AGAIN"

	play_again_button.pressed.connect(_on_play_again_pressed)

	# Check regular apples only
	if ProgressManager.collected_apples.size() >= 8:
		ending_title.text = "YOU WIN!!!"
		play_again_button.visible = false
	else:
		ending_title.text = "YOU LOSE!"
		play_again_button.visible = true


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
