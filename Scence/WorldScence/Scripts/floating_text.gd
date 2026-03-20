extends Node2D

@onready var label: Label = $Label

func setup(text: String):
	label.text = text
	
	position.y += 10

	var tween = create_tween()

	# Float upward slowly (5 seconds)
	tween.parallel().tween_property(self, "position:y", position.y - 50, 7.0)

	# Fade out slowly (5 seconds)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 5.0)

	await tween.finished
	queue_free()
