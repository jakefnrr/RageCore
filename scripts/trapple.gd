
extends Area2D

@onready var sound = $sound
@onready var picture = $CanvasLayer/picture
@onready var apple_sprite = $AnimatedSprite2D
@onready var apple_collision = $CollisionShape2D

var collected = false

func _ready():
	picture.hide()
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if collected:
		return

	# Detect the player by its node type
	if not body is CharacterBody2D:
		return

	collected = true

	monitoring = false
	apple_collision.set_deferred("disabled", true)

	apple_sprite.hide()
	picture.show()

	sound.play()
	await sound.finished

	picture.hide()
	queue_free()
