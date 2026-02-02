extends CanvasLayer

func _ready():
	GameManager.gained_coins.connect(update_coin_display)

	await get_tree().process_frame
	GameManager.player.health_changed.connect(update_health_display)
	update_health_display(GameManager.player.health, GameManager.player.max_health)

func update_coin_display():
	$CoinDisplay.text = str(GameManager.coins)

func update_health_display(current_health, max_health):
	$HealthDisplay.text = "Health: " + str(current_health) + " / " + str(max_health)
