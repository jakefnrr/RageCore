
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var death_text: Label = $CanvasLayer/DeathText

const SPEED = 300.0
const JUMP_VELOCITY = -750.0
const LEVEL_1_PATH = "res://scenes/level1.tscn"
const MOBILE_SCREEN_SHIFT = 180.0

var jumps_remaining = 0
var has_jumped = false
var is_dead = false
var flashing = false
var mobile_controls_created := false


func _ready() -> void:
	death_text.hide()
	death_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_text.add_theme_font_size_override("font_size", 80)
	$CanvasLayer.follow_viewport_enabled = false

	if OS.has_feature("mobile") or DisplayServer.is_touchscreen_available():
		create_mobile_controls()

	release_move_actions()


func _exit_tree() -> void:
	get_tree().root.canvas_transform = Transform2D.IDENTITY
	release_move_actions()


func release_move_actions() -> void:
	Input.action_release("jump")
	Input.action_release("left")
	Input.action_release("right")


func _input(event: InputEvent) -> void:
	if not mobile_controls_created and event is InputEventScreenTouch:
		create_mobile_controls()


func create_mobile_controls() -> void:
	if mobile_controls_created:
		return

	mobile_controls_created = true

	var mobile_layer := CanvasLayer.new()
	mobile_layer.name = "MobileControls"
	mobile_layer.layer = 10
	mobile_layer.follow_viewport_enabled = false
	add_child(mobile_layer)

	get_tree().root.canvas_transform = Transform2D(0, Vector2(0, -MOBILE_SCREEN_SHIFT))

	var controls := Control.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls.mouse_filter = Control.MOUSE_FILTER_PASS
	mobile_layer.add_child(controls)

	# JUMP - BOTTOM LEFT
	create_button(
		controls,
		"JUMP",
		"jump",
		0.02, 0.68, 0.26, 0.995,
		30
	)

	# LEFT - BOTTOM RIGHT
	create_button(
		controls,
		"◀",
		"left",
		0.68, 0.74, 0.82, 0.995,
		40
	)

	# RIGHT - BOTTOM RIGHT
	create_button(
		controls,
		"▶",
		"right",
		0.83, 0.74, 0.97, 0.995,
		40
	)


func create_button(
	parent: Control,
	button_text: String,
	action_name: String,
	left: float,
	top: float,
	right: float,
	bottom: float,
	font_size: int = 30
) -> void:
	var button := Button.new()
	button.text = button_text

	button.anchor_left = left
	button.anchor_top = top
	button.anchor_right = right
	button.anchor_bottom = bottom

	button.offset_left = 0
	button.offset_top = 0
	button.offset_right = 0
	button.offset_bottom = 0

	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color.WHITE)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.12, 0.08, 0.85)
	normal.set_border_width_all(3)
	normal.border_color = Color(0.2, 1.0, 0.3)
	normal.set_corner_radius_all(18)

	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.15, 0.55, 0.2, 0.95)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)

	button.button_down.connect(func():
		Input.action_press(action_name)
	)

	button.button_up.connect(func():
		Input.action_release(action_name)
	)

	parent.add_child(button)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		jumps_remaining = 2
		has_jumped = false

	if Input.is_action_just_pressed("jump") and jumps_remaining > 0:
		velocity.y = JUMP_VELOCITY
		jumps_remaining -= 1
		has_jumped = true
		jump_sound.play()

	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if not is_on_floor():
		if jumps_remaining == 1:
			animated_sprite_2d.animation = "jumping"
		elif jumps_remaining == 0:
			animated_sprite_2d.animation = "doublejump"
	elif direction != 0:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"

	if direction == 1.0:
		animated_sprite_2d.flip_h = false
	elif direction == -1.0:
		animated_sprite_2d.flip_h = true

	move_and_slide()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	Input.action_release("jump")
	Input.action_release("left")
	Input.action_release("right")

	death_text.text = "GG NOOB"
	death_text.show()

	animated_sprite_2d.play("dying")
	death_sound.play()

	flashing = true
	flash_colors()

	await death_sound.finished

	flashing = false
	get_tree().change_scene_to_file(LEVEL_1_PATH)


func flash_colors() -> void:
	var colors = [Color.RED, Color.GREEN, Color.WHITE]
	var color_index = 0

	while flashing:
		death_text.add_theme_color_override("font_color", colors[color_index])
		color_index = (color_index + 1) % colors.size()
		await get_tree().create_timer(0.1).timeout
