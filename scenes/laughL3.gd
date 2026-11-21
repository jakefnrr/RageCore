
extends Area2D

@onready var sound: AudioStreamPlayer2D = $sound

@onready var picture = $CanvasLayer/picture
@onready var collision = $CollisionShape2D

var triggered = false

func _ready():
	picture.hide()
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if triggered:
		return

	if not body is CharacterBody2D:
		return

	triggered = true

	monitoring = false
	collision.set_deferred("disabled", true)

	# Wait 0.1 seconds
	await get_tree().create_timer(0.1).timeout

	# Show cat picture
	picture.show()

	# Play laughing sound
	sound.play()

	# Wait for sound to finish
	await sound.finished

	# Hide picture
	picture.hide()

	# Load level 1
	get_tree().change_scene_to_file("res://scenes/leve1.tscn")
