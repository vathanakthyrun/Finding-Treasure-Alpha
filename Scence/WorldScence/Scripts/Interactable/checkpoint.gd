extends Node2D
class_name Checkpoint

@onready var activate_sound: AudioStreamPlayer2D = $ActivateSound
@onready var win_sound: AudioStreamPlayer2D = $WinSound   

@export var spawnpoint = false
@export var win_condition = false

var activated = false
var floating_text_scene = preload("res://Scence/WorldScence/floating_text.tscn")

func _ready():
	if spawnpoint:
		activate()

func activate():

	activated = true
	GameManager.current_checkpoint = self
	$AnimationPlayer.play("Activated")

	# 🔥 If win condition → play win sound
	if win_condition:
		win_sound.play()
		GameManager.win()
	else:
		activate_sound.play()

	# Floating text
	var text_instance = floating_text_scene.instantiate()
	text_instance.global_position = global_position + Vector2(0, -40)
	get_tree().current_scene.add_child(text_instance)
	text_instance.setup("Respect+++")
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player && !activated:
		activate()
