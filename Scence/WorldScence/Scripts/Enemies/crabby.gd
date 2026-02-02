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
	

func _on_animation_finished(anim_name: String):
	if anim_name == "Die":
		queue_free()



func _physics_process(delta: float) -> void:

	if dead:
		return   # HARD STOP

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Edge detection
	if not raycast.is_colliding() and is_on_floor():
		flip()

	velocity.x = direction * move_speed
	move_and_slide()


func flip():
	direction *= -1
	scale.x *= -1


# Enemy touches player → player dies
func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.get_parent() is Player:
		area.get_parent().take_damage(1)


# Called by player attack
func die():
	if dead:
		return

	dead = true

	# STOP EVERYTHING
	set_physics_process(false)
	velocity = Vector2.ZERO

	# Disable collision
	collision.disabled = true
	hitbox.monitoring = false

	# FORCE play Die animation
	animation.stop()
	animation.play("Die")
