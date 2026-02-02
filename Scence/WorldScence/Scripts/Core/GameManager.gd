extends Node

signal gained_coins()

var coins : int

var player: Player
var current_checkpoint: Checkpoint

func respawn_player():
	player.health = player.max_health
	if current_checkpoint:
		player.global_position = current_checkpoint.global_position
	else:
		player.global_position = Vector2.ZERO

func gain_coins(coins_gained:int):
	coins += coins_gained
	emit_signal("gained_coins")
	print(coins)
