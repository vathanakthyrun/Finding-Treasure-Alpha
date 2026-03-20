extends Node2D

@onready var music = $AudioStreamPlayer2D
@onready var label = $Label

var player_near = false


func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		if music.playing:
			music.stop()
			label.text = "[E] Play Music"
		else:
			music.play()
			label.text = "[E] Stop Music"


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_near = true
		label.visible = true


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_near = false
		label.visible = false
