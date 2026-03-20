extends Node2D

@export var target_scene : String
@export var target_door_id : String
@export var door_id : String

@onready var animation = $AnimationPlayer
@onready var label = $Label

var player_near = false
var opening = false


func _process(delta):

	if player_near and Input.is_action_just_pressed("interact") and !opening:
		open_door()


func open_door():

	opening = true
	label.visible = false

	GameManager.next_spawn_door = target_door_id

	animation.play("open")
	
func switch_level():

	var world = get_tree().current_scene

	world.get_node("Level1").visible = false
	world.get_node("Level2").visible = true
	
func switch_back():

	var world = get_tree().current_scene

	world.get_node("Level2").visible = false
	world.get_node("Level1").visible = true


func _on_animation_player_animation_finished(anim_name):

	if anim_name == "open":
		get_tree().change_scene_to_file(target_scene)


func _on_area_2d_body_entered(body):

	if body.is_in_group("player"):
		player_near = true
		label.visible = true


func _on_area_2d_body_exited(body):

	if body.is_in_group("player"):
		player_near = false
		label.visible = false

func go_to_level2():

	var world = get_tree().current_scene
	
	world.get_node("Level1").visible = false
	world.get_node("Level2").visible = true

	var spawn = world.get_node("Level2/DoorSpawn_Level2")
	GameManager.player.global_position = spawn.global_position
	
func go_to_level1():

	var world = get_tree().current_scene
	
	world.get_node("Level2").visible = false
	world.get_node("Level1").visible = true

	var spawn = world.get_node("Level1/DoorSpawn_Level1")
	GameManager.player.global_position = spawn.global_position
