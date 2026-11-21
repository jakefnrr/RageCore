
extends Area2D

@onready var apple_sound: AudioStreamPlayer2D = $AppleSound

@export_range(1, 8) var level_number: int = 1

var collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not collected:
		collected = true

		ProgressManager.collect_apple(level_number)

		var sound := AudioStreamPlayer2D.new()
		sound.stream = apple_sound.stream
		sound.volume_db = apple_sound.volume_db

		get_tree().current_scene.add_child(sound)
		sound.global_position = global_position
		sound.finished.connect(sound.queue_free)
		sound.play()

		queue_free()
