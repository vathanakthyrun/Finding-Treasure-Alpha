extends CanvasLayer

@onready var menu_music = preload("res://used_asset/Music/backgroundSound.ogg")  

func _ready():
	MusicManager.play_music(menu_music)


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		start_game()

func start_game():
	get_tree().change_scene_to_file("res://Scence/WorldScence/level_one.tscn")
