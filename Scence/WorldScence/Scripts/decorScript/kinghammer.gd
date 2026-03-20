extends Node2D

var player_near = false
var dialogue_index = 0
var talking = false

@onready var audio = $AudioStreamPlayer2D
@onready var talk_label = $Label
@onready var subtitle = get_tree().get_first_node_in_group("subtitle") 

var dialogue_sounds = [
	preload("res://used_asset/Music/SFX/gta-san-andreas-ah-shit-here-we-go-again.ogg"),
	preload("res://used_asset/Music/SFX/rizz-sound-effect.ogg"),
	preload("res://used_asset/Music/SFX/gta-san-andreas-ah-shit-here-we-go-again.ogg")
]

var subtitles = [
	"Welcome warrior...",
	"The kingdom is in danger...",
	"You must defeat the darkness."
]

func _ready():
	talk_label.visible = false


func _process(delta):

	if player_near:
		if Input.is_action_just_pressed("interact"):
			print("Interaction triggered")
			start_dialogue()


func start_dialogue():

	talking = true
	dialogue_index = 0

	talk_label.visible = false

	play_dialogue()


func play_dialogue():

	audio.stream = dialogue_sounds[dialogue_index]
	audio.play()

	get_tree().get_first_node_in_group("subtitle").text = subtitles[dialogue_index]
	get_tree().get_first_node_in_group("subtitle").visible = true


func next_dialogue():

	dialogue_index += 1

	if dialogue_index >= dialogue_sounds.size():
		end_dialogue()
	else:
		play_dialogue()


func end_dialogue():

	talking = false
	var subtitle = get_tree().get_first_node_in_group("subtitle")
	subtitle.visible = false


func _on_area_2d_body_entered(body):
	print("Something entered:", body.name)

	if body.name == "player":
		player_near = true
		$Label.visible = true


func _on_area_2d_body_exited(body):
	if body.name == "player":
		player_near = false
		$Label.visible = false
