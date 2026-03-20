extends CanvasLayer

@onready var overlay = $DarkOverlay
@onready var pause_menu = $PauseMenu


func _ready():
	GameManager.pause_menu = $PauseMenu
	GameManager.win_screen = $WinScreen
	GameManager.score_label = $WinScreen/Label
	GameManager.gained_coins.connect(update_coin_display)

	await get_tree().process_frame
	GameManager.player.health_changed.connect(update_health_display)
	update_health_display(GameManager.player.health, GameManager.player.max_health)
	
	GameManager.player.lives_changed.connect(update_lives_display)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		GameManager.pause_play()

	
func update_coin_display():
	$CoinDisplay.text = str(GameManager.coins)

func update_health_display(current_health, max_health):
	$HealthDisplay.text = "Health: " + str(current_health) + " / " + str(max_health)

func update_lives_display(current_lives):
	$LivesDisplay.text = "Lives: " + str(current_lives)


func _on_resume_pressed() -> void:
	GameManager.resume()


func _on_restart_pressed() -> void:
	GameManager.restart()


func _on_quit_pressed() -> void:
	GameManager.quit()

func fade_pause(state: bool):
	var tween = create_tween()

	if state:
		overlay.visible = true
		tween.tween_property(overlay, "color:a", 0.6, 0.3)
		await tween.finished
		
		pause_menu.visible = true
		get_tree().paused = true
	else:
		get_tree().paused = false
		pause_menu.visible = false
		
		tween.tween_property(overlay, "color:a", 0.0, 0.3)
		await tween.finished
		
		overlay.visible = false
