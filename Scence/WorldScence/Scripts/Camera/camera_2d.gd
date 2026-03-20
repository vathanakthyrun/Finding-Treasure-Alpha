extends Camera2D

@export var shake_strength: float = 8.0
@export var shake_fade: float = 15.0

var shake_intensity: float = 0.0

func _process(delta):
	if shake_intensity > 0:
		offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)

		shake_intensity = lerp(shake_intensity, 0.0, shake_fade * delta)

		if shake_intensity < 0.1:
			shake_intensity = 0
			offset = Vector2.ZERO


func shake(amount: float):
	shake_intensity = amount
