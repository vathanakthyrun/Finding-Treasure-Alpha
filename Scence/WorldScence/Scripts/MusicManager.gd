extends Node

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "Music"  # or "Music" if you have one
	player.autoplay = false

func play_music(stream: AudioStream):
	if player.stream == stream and player.playing:
		return
		
	player.stream = stream
	player.play()

func stop_music():
	player.stop()
