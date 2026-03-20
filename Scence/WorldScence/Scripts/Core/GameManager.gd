extends Node

signal gained_coins()

var coins : int
var score : int = 0
var player: Player
var current_checkpoint: Checkpoint
var pause_menu
var paused = false
var win_screen
var score_label
var next_spawn_door = "" 

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

func reset_pickups():
	var pickups = get_tree().get_nodes_in_group("Pickups")
	for pickup in pickups:
		if pickup.has_method("reset_pickup"):
			pickup.reset_pickup()

func reset_world_objects():
	var objects = get_tree().get_nodes_in_group("Resettable")
	for obj in objects:
		if obj.has_method("reset_object"):
			obj.reset_object()

func win():
	win_screen.visible = true
	
	score_label.text = "score:" + str(score)

	# 🔥 Stop player movement
	if player:
		player.set_physics_process(false)
		player.set_process(false)

func pause_play():
	paused = !paused
	pause_menu.get_parent().fade_pause(paused)


	

func resume():
	
	pause_play()

func restart():
	coins = 0
	score = 0
	get_tree().reload_current_scene()

func quit():
	get_tree().quit()
