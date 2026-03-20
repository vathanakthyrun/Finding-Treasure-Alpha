extends CharacterBody2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea


@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var blow_sound: AudioStreamPlayer2D = $BlowSound

@onready var blow_area: Area2D = $BlowArea

@export var move_speed: float = 40.0
@export var max_health: int = 3
@export var blow_force: float = 700
@export var blow_cooldown: float = 3.0
@export var blow_charge_time := 0.6

var health: int
var direction: int = -1
var dead := false

var player_in_range := false
var can_blow := true
var blowing := false

func _ready():
	health = max_health
	animation.play("Run")
	animation.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name == "Hit" and not dead:
		set_physics_process(true)
		animation.play("Run")

func _physics_process(delta):

	if dead or blowing:
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


func take_damage(amount):

	if dead:
		return

	health -= amount

	if health > 0:
		hit_sound.pitch_scale = randf_range(0.95, 1.05)
		hit_sound.play()

		set_physics_process(false)
		animation.play("Hit")
	else:
		die()
		
func die():

	if dead:
		return

	GameManager.score += 100
	dead = true

	set_physics_process(false)
	velocity = Vector2.ZERO

	collision.disabled = true
	hit_area.monitoring = false


	death_sound.pitch_scale = randf_range(0.95, 1.05)
	death_sound.play()

	animation.play("Die")

	await animation.animation_finished
	visible = false

func _on_blow_area_body_entered(body):
	if dead:
		return

	if body is Player:

		var player = body
		var blow_dir = sign(player.global_position.x - global_position.x)

		player.apply_knockback_from_wind(blow_dir, blow_force)

func _on_blow_area_body_exited(body):
	if body is Player:
		player_in_range = false

func try_blow(player):

	if not can_blow or dead:
		return

	can_blow = false
	blowing = true

	set_physics_process(false)

	animation.play("Blow")

	await get_tree().create_timer(0.3).timeout

	# PLAY BLOW SOUND
	blow_sound.pitch_scale = randf_range(0.95, 1.05)
	blow_sound.play()

	# APPLY KNOCKBACK
	var dir = sign(player.global_position.x - global_position.x)
	player.apply_knockback_from_wind(dir, blow_force)

	await get_tree().create_timer(0.4).timeout

	blowing = false
	set_physics_process(true)
	animation.play("Run")

	await get_tree().create_timer(blow_cooldown).timeout
	can_blow = true

func step_shake():
	if GameManager.player and is_on_screen():
		GameManager.player.camera.shake(4)

func is_on_screen() -> bool:
	if GameManager.player == null:
		return false
		
	var cam = GameManager.player.camera
	var screen_rect = Rect2(
		cam.global_position - (get_viewport_rect().size * cam.zoom) / 2,
		get_viewport_rect().size * cam.zoom
	)

	return screen_rect.has_point(global_position)

func reset_object():
	dead = false
	health = max_health
	
	visible = true
	collision.disabled = false
	hit_area.monitoring = true

	
	set_physics_process(true)
	animation.play("Run")


func _on_hit_area_area_entered(area: Area2D) -> void:
	if dead:
		return

	if area.get_parent() is Player:
		var player = area.get_parent()
		player.take_damage(1, global_position)
