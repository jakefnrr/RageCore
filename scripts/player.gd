
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var death_text: Label = $CanvasLayer/DeathText

const SPEED = 300.0
const JUMP_VELOCITY = -750.0
const LEVEL_1_PATH = "res://scenes/level1.tscn"

var jumps_remaining = 0
var has_jumped = false
var is_dead = false
var flashing = false

func _ready() -> void:
	death_text.hide()
	death_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_text.add_theme_font_size_override("font_size", 80)


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
