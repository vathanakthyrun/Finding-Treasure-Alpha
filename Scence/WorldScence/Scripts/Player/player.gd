extends CharacterBody2D
class_name Player

signal health_changed(current_health, max_health)

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $FlipPivot/Sprite2D
@onready var attack_area: Area2D = $FlipPivot/AttackArea
@onready var flip_pivot: Node2D = $FlipPivot
@onready var camera: Camera2D = $Camera2D
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var footstep_sound: AudioStreamPlayer2D = $FootstepSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound

# -------------------
# Movement Settings
# -------------------
@export var speed: float = 250.0
@export var acceleration: float = 800.0
@export var friction: float = 800.0
@export var jump_force: float = 300.0
@export var max_jumps: int = 2

# -------------------
# Dash Settings
# -------------------
@export var dash_speed: float = 400.0
@export var dash_time: float = 0.2
@export var dash_cooldown: float = 0.5

# -------------------
# Dash Settings
# -------------------
@export var knockback_force: float = 250.0
@export var knockback_up_force: float = 150.0

# -------------------
# Variables
# -------------------
var jump_count: int = 0
var can_air_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var attacking: bool = false
var is_hurt: bool = false
var knockback_direction: int = 0
var is_dead: bool = false
var default_zoom: Vector2
var is_invincible: bool = false
var invincible_tween: Tween
var rainbow_time := 0.0
var is_speed_boosted: bool = false
var speed_tween: Tween
var original_speed: float
var original_dash_speed: float
var facing_direction: int = 1
var attack_offset_x: float




# -------------------
# Health
# -------------------
@export var base_max_health: int = 3
var max_health: int
var health: int = 0
var can_take_damage: bool = true

# =====================================================
# READY
# =====================================================
func _ready():
	max_health = base_max_health
	health = max_health
	default_zoom = camera.zoom
	original_speed = speed
	original_dash_speed = dash_speed

	lives = base_lives
	emit_signal("lives_changed", lives)

	GameManager.player = self
	animation.animation_finished.connect(_on_animation_finished)
	attack_area.monitoring = false
	attack_offset_x = attack_area.position.x
	
	emit_signal("health_changed", health, max_health)

	# 🔹 Spawn player at correct door
	for door in get_tree().get_nodes_in_group("doors"):
		if "door_id" in door and door.door_id == GameManager.next_spawn_door:
			global_position = door.global_position

# =====================================================
# PROCESS
# =====================================================
func _process(delta):
	if is_invincible:
		rainbow_time += delta * 4.0
		var hue = fmod(rainbow_time, 1.0)
		sprite.modulate = Color.from_hsv(hue, 1, 1)

	if Input.is_action_just_pressed("attack"):
		attack()


# =====================================================
# PHYSICS
# =====================================================
func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var direction := Input.get_axis("left", "right")

	# 1. HANDLE FLIPPING
	# We only scale the FlipPivot. This flips the Sprite AND the Hitbox together.
	if direction != 0:
		facing_direction = sign(direction)
		$FlipPivot.scale.x = facing_direction

	# 2. GROUNDED RESET
	if is_on_floor():
		jump_count = 0
		can_air_dash = true

	# 3. DASH COOLDOWN
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# 4. DASH INPUT
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		if is_on_floor() or can_air_dash:
			start_dash()
			dash_sound.pitch_scale = randf_range(0.95, 1.05)
			dash_sound.play()
			if not is_on_floor():
				can_air_dash = false

	# 5. MOVEMENT LOGIC
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
	else:
		handle_movement(delta)

	# 6. APPLY PHYSICS
	move_and_slide()
	update_animation()
	handle_footsteps()


	# 7. DEATH CHECK
	if global_position.y >= 450:
		die()

# =====================================================
# MOVEMENT
# =====================================================
func handle_movement(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = -jump_force
		jump_count += 1

	if attacking:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		return

	var direction := Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_footsteps():
	if abs(velocity.x) > 10 and is_on_floor() and not is_dashing and not is_dead:
		if not footstep_sound.playing:
			footstep_sound.play()
	else:
		if footstep_sound.playing:
			footstep_sound.stop()

# =====================================================
# DASH
# =====================================================
func start_dash() -> void:
	is_dashing = true
	dash_timer = dash_time

	var direction := Input.get_axis("left", "right")
	if direction == 0:
		direction = sign(sprite.scale.x)

	velocity.y = 0
	velocity.x = direction * dash_speed

# =====================================================
# ATTACK
# =====================================================
func attack():
	if attacking:
		return

	attacking = true
	animation.play("Attack")
	attack_area.monitoring = true
	attack_sound.pitch_scale = randf_range(0.95, 1.05)
	attack_sound.play()

	await get_tree().create_timer(0.05).timeout

	var overlapping_objects = attack_area.get_overlapping_areas()

	for area in overlapping_objects:
		var parent = area.get_parent()
		if parent.is_in_group("Enemies"):
			parent.take_damage(1)


func _on_animation_finished(anim_name: String):
	if anim_name == "Attack":
		attacking = false
		attack_area.monitoring = false
	
	if anim_name == "Hit":
		is_hurt = false


# =====================================================
# ANIMATION
# =====================================================
func update_animation() -> void:

	if attacking or is_hurt:
		return

	if is_dashing:
		if animation.current_animation != "Dash":
			animation.play("Dash")
		return

	if velocity.y < 0:
		if animation.current_animation != "Jump":
			animation.play("Jump")
			jump_sound.pitch_scale = randf_range(0.95, 1.05)
			jump_sound.play()
		return

	if velocity.y > 0 and not is_on_floor():
		if animation.current_animation != "Fall":
			animation.play("Fall")
		return

	if abs(velocity.x) > 10:
		if animation.current_animation != "Run":
			animation.play("Run")
	else:
		if animation.current_animation != "Idle":
			animation.play("Idle")
		


# =====================================================
# HEALTH SYSTEM
# =====================================================
func take_damage(damage_amount: int, enemy_position: Vector2, knockback_multiplier: float = 1.0):
	if can_take_damage and not is_invincible:
		health -= damage_amount
		emit_signal("health_changed", health, max_health)

		knockback_direction = sign(global_position.x - enemy_position.x)

		apply_knockback(knockback_multiplier)
		play_hit_animation()
		camera.shake(10)
		iframes()
		hit_sound.play()


	if health <= 0:
		die()



func apply_knockback(multiplier: float):
	velocity.x = knockback_direction * knockback_force * multiplier
	velocity.y = -knockback_up_force * multiplier




func heal(amount: int):
	health += amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

func increase_max_health(amount: int):
	max_health += amount
	health += amount
	emit_signal("health_changed", health, max_health)
	
func play_hit_animation():
	if is_hurt:
		return

	attacking = false
	attack_area.monitoring = false

	is_hurt = true
	animation.play("Hit")

	await get_tree().create_timer(0.4).timeout
	is_hurt = false



func iframes():
	can_take_damage = false
	await get_tree().create_timer(1).timeout
	can_take_damage = true

# -------------------
# Lives System
# -------------------
@export var base_lives: int = 3
var lives: int
signal lives_changed(current_lives)


# =====================================================
# DEATH / RESPAWN
# =====================================================
func die():
	deactivate_speed_boost()

	if is_dead:
		return

	is_dead = true
	attacking = false
	is_hurt = false
	attack_area.monitoring = false
	velocity = Vector2.ZERO
	is_invincible = false
	stop_invincible_effect()
	deactivate_speed_boost()

	# 🔥 Play death sound here
	death_sound.pitch_scale = randf_range(0.95, 1.05)
	death_sound.play()

	animation.play("Death")

	await death_zoom()

	await animation.animation_finished

	await get_tree().create_timer(0.3).timeout

	lives -= 1
	emit_signal("lives_changed", lives)

	if lives > 0:
		max_health = base_max_health
		health = max_health
		GameManager.respawn_player()
		emit_signal("health_changed", health, max_health)
	else:
		reset_game()

	reset_zoom()

	is_dead = false



func reset_game():
	lives = base_lives
	emit_signal("lives_changed", lives)

	max_health = base_max_health
	health = max_health
	emit_signal("health_changed", health, max_health)

	GameManager.current_checkpoint = null
	GameManager.respawn_player()

	GameManager.reset_world_objects()
	
func death_zoom():
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(0.6, 0.6), 0.3)
	await tween.finished

func reset_zoom():
	var tween = create_tween()
	tween.tween_property(camera, "zoom", default_zoom, 0.3)
	
func activate_invincibility(duration: float):
	if is_invincible:
		return

	is_invincible = true

	start_invincible_effect()

	await get_tree().create_timer(duration).timeout

	is_invincible = false
	stop_invincible_effect()

func start_invincible_effect():
	invincible_tween = create_tween()
	invincible_tween.set_loops()

	var colors = [
		Color(1, 0, 0),   # Red
		Color(1, 0.5, 0), # Orange
		Color(1, 1, 0),   # Yellow
		Color(0, 1, 0),   # Green
		Color(0, 0, 1),   # Blue
		Color(0.6, 0, 1)  # Purple
	]

	for c in colors:
		invincible_tween.tween_property(sprite, "modulate", c, 0.1)

	# Back to white before repeating
	invincible_tween.tween_property(sprite, "modulate", Color(1,1,1), 0.1)


func stop_invincible_effect():
	if invincible_tween:
		invincible_tween.kill()
		invincible_tween = null
		sprite.modulate = Color(1,1,1)
		rainbow_time = 0.0

func activate_speed_boost(duration: float):
	if is_speed_boosted:
		return

	is_speed_boosted = true

	speed *= 2
	dash_speed *= 2

	start_speed_effect()
	zoom_out_for_speed()

	await get_tree().create_timer(duration).timeout

	deactivate_speed_boost()

func zoom_out_for_speed():
	var tween = create_tween()
	tween.tween_property(camera, "zoom", default_zoom * 0.8, 0.3)


func deactivate_speed_boost():
	is_speed_boosted = false

	speed = original_speed
	dash_speed = original_dash_speed

	stop_speed_effect()

	var tween = create_tween()
	tween.tween_property(camera, "zoom", default_zoom, 0.3)


func start_speed_effect():
	speed_tween = create_tween()
	speed_tween.set_loops()
	speed_tween.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.1)
	speed_tween.tween_property(sprite, "scale", Vector2(1, 1), 0.1)


func stop_speed_effect():
	if speed_tween:
		speed_tween.kill()
		speed_tween = null

	sprite.scale = Vector2(sign(sprite.scale.x), 1)
	

func apply_knockback_from_wind(direction: int, force: float):

	# Cancel dash / attack so player reacts properly
	is_dashing = false
	attacking = false

	velocity.x = direction * force
	velocity.y = -150
