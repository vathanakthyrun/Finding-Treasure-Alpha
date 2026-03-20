extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Area2D

@export var move_speed: float = 60.0
@export var max_health: int = 3

var direction: int = -1
var dead: bool = false
var health: int


func _ready():
	health = max_health
	sprite.play("Run")


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
	sprite.flip_h = direction > 0
	raycast.target_position.x = abs(raycast.target_position.x) * direction


func _on_area_2d_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.get_parent() is Player:
		var player = area.get_parent()
		player.take_damage(1, global_position)


# 🔥 NEW DAMAGE FUNCTION
func take_damage(amount: int):
	if dead:
		return

	health -= amount

	if health > 0:
		play_hit()
	else:
		die()


func play_hit():
	set_physics_process(false)
	sprite.play("Hit")
	await sprite.animation_finished
	set_physics_process(true)
	sprite.play("Run")


func die():
	GameManager.score += 100

	if dead:
		return

	dead = true

	set_physics_process(false)
	velocity = Vector2.ZERO
	collision.disabled = true
	hitbox.monitoring = false

	sprite.play("Die")
	await sprite.animation_finished

	visible = false


# 👇 Reset support
func reset_object():
	dead = false
	health = max_health

	visible = true
	collision.disabled = false
	hitbox.monitoring = true
	set_physics_process(true)

	sprite.play("Run")
