extends Node2D



func _on_area_2d_area_entered(area: Area2D) -> void:
	var player = area.get_parent()

	player.max_health += 1
	player.health += 1
	player.emit_signal("health_changed", player.health, player.max_health)

	queue_free()
