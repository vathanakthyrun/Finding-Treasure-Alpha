extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	$AnimationPlayer.play("Crumble")
	await $AnimationPlayer.animation_finished
	
