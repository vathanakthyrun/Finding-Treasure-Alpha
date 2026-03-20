extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

var collected := false

func _ready():
	animation.play("Idle")


func _on_area_2d_body_entered(body: Node) -> void:
	if collected:
		return
		
	if body is Player:
		collected = true
		
		GameManager.gain_coins(1)
		GameManager.score += 50

		# Play sound with slight pitch variation
		pickup_sound.pitch_scale = randf_range(0.95, 1.1)
		pickup_sound.play()

		# Disable collision immediately
		collision.disabled = true
		
		# Hide sprite but let sound finish
		hide()
		
		await pickup_sound.finished
		
		# Now fully deactivate
		visible = false


func reset_object():
	collected = false
	visible = true
	show()
	collision.disabled = false
