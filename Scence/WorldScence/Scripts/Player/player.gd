extends CharacterBody2D
class_name Player

signal health_changed(current_health, max_health)

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea

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
# Variables
# -------------------
var jump_count: int = 0
var can_air_dash: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var attacking: bool = false

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
	
	GameManager.player = self
	animation.animation_finished.connect(_on_animation_finished)
	attack_area.monitoring = false
	
	emit_signal("health_changed", health, max_health)


# =====================================================
# PROCESS
# =====================================================
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		attack()

# =====================================================
# PHYSICS
# =====================================================
func _physics_process(delta: float) -> void:

	var direction := Input.get_axis("left", "right")

	# Flip sprite
	if direction != 0:
		sprite.scale.x = sign(direction)

	# Move attack hitbox
	var offset: float = abs(attack_area.position.x)
	if direction != 0:
		attack_area.position.x = offset * sign(direction)

	# Reset jump & dash when grounded
	if is_on_floor():
		jump_count = 0
		can_air_dash = true

	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Dash input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		if is_on_floor() or can_air_dash:
			start_dash()
			if not is_on_floor():
				can_air_dash = false

	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = dash_cooldown
	else:
		handle_movement(delta)

	move_and_slide()
	update_animation()

	# Fall death check
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

	await get_tree().create_timer(0.05).timeout

	var overlapping_objects = attack_area.get_overlapping_areas()

	for area in overlapping_objects:
		var parent = area.get_parent()
		if parent.is_in_group("Enemies"):
			parent.die()

func _on_animation_finished(anim_name: String):
	if anim_name == "Attack":
		attacking = false
		attack_area.monitoring = false

# =====================================================
# ANIMATION
# =====================================================
func update_animation() -> void:

	if attacking:
		return

	if is_dashing:
		if animation.current_animation != "Dash":
			animation.play("Dash")
		return

	if velocity.y < 0:
		if animation.current_animation != "Jump":
			animation.play("Jump")
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
func take_damage(damage_amount: int):
	if can_take_damage:
		health -= damage_amount
		emit_signal("health_changed", health, max_health)
		iframes()

	if health <= 0:
		die()

func heal(amount: int):
	health += amount
	health = clamp(health, 0, max_health)
	emit_signal("health_changed", health, max_health)

func increase_max_health(amount: int):
	max_health += amount
	health += amount
	emit_signal("health_changed", health, max_health)

func iframes():
	can_take_damage = false
	await get_tree().create_timer(1).timeout
	can_take_damage = true

# =====================================================
# DEATH / RESPAWN
# =====================================================
func die():
	# Reset to original hearts
	max_health = base_max_health
	health = max_health
	
	GameManager.respawn_player()
	emit_signal("health_changed", health, max_health)
