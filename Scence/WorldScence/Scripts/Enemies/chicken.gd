extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Area2D

@export var move_speed: float = 60.0

var direction: int = -1


func _ready():
	sprite.play("Run")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not raycast.is_colliding() and is_on_floor():
		flip()

	velocity.x = direction * move_speed
	move_and_slide()


func flip():
	direction *= -1
	sprite.flip_h = direction > 0
	raycast.target_position.x = abs(raycast.target_position.x) * direction


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player = area.get_parent()
		player.take_damage(1, global_position)


# 🛡️ IMMORTAL — Ignore all damage
func take_damage(amount: int):
	pass


# 🔁 Reset support (still works if using object pooling)
func reset_object():
	visible = true
	collision.disabled = false
	hitbox.monitoring = true
	set_physics_process(true)

	sprite.play("Run")
