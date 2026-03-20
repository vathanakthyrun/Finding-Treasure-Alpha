extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Area2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound


@export var move_speed: float = 80.0
@export var max_health: int = 3
var health: int

var direction: int = -1
var dead: bool = false


func _ready():
	health = max_health
	animation.play("Run")
	animation.animation_finished.connect(_on_animation_finished)


func _on_animation_finished(anim_name: String):
	if anim_name == "Hit" and not dead:
		set_physics_process(true)
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
		player.take_damage(1, global_position)

func take_damage(amount: int):
	if dead:
		return

	health -= amount

	if health > 0:
		# Play hit sound
		hit_sound.pitch_scale = randf_range(0.95, 1.05)
		hit_sound.play()

		set_physics_process(false)
		animation.play("Hit")
	else:
		die()




func die():
	GameManager.score += 100

	if dead:
		return

	dead = true

	set_physics_process(false)
	velocity = Vector2.ZERO

	collision.disabled = true
	hitbox.monitoring = false

	# Play death sound
	death_sound.pitch_scale = randf_range(0.95, 1.05)
	death_sound.play()

	animation.stop()
	animation.play("Die")

	await animation.animation_finished

	visible = false



# VERY IMPORTANT (for reset system)
func reset_object():
	dead = false
	health = max_health
	
	visible = true
	collision.disabled = false
	hitbox.monitoring = true
	set_physics_process(true)
	
	animation.play("Run")
