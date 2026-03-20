extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

var collected := false

func _ready():
	animation.play("Idle")

func _on_area_2d_body_entered(body: Node) -> void:
	if collected:
		return

	if body is Player:
		collected = true
		
		body.activate_speed_boost(10.0)
		
		visible = false
		collision.disabled = true


func reset_object():
	collected = false
	visible = true
	collision.disabled = false
