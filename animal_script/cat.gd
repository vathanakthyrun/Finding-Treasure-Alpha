extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Area2D

@export var move_speed: float = 60.0

var direction: int = -1
var dead: bool = false


func _ready():
	animation.play("Run")


func _physics_process(delta: float) -> void:

	if dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if not raycast.is_colliding() and is_on_floor():
		flip()

	velocity.x = direction * move_speed
	move_and_slide()


func flip():
	direction *= -1
	scale.x *= -1


func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.get_parent() is Player:
		var player = area.get_parent()
		player.take_damage(3, global_position)


func die():
	GameManager.score += 100
	if dead:
		return

	dead = true

	set_physics_process(false)
	velocity = Vector2.ZERO

	collision.disabled = true
	hitbox.monitoring = false

	animation.stop()
	animation.play("Die")

	await animation.animation_finished

	# Instead of queue_free, hide it
	visible = false


# 👇 VERY IMPORTANT (for reset system)
func reset_object():
	dead = false
	
	visible = true
	collision.disabled = false
	hitbox.monitoring = true
	
	set_physics_process(true)
	
	animation.play("Run")
