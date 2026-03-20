extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D
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
		pickup_sound.pitch_scale = randf_range(0.95, 1.1)
		pickup_sound.play()
		
		body.lives += 1
		body.emit_signal("lives_changed", body.lives)
		
		visible = false
		collision.disabled = true


func reset_object():
	collected = false
	visible = true
	collision.disabled = false
