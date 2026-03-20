extends StaticBody2D

var cannon_ball = load("res://Scence/WorldScence/Interactable/canon_ball.tscn")
var debris = load("res://Scence/WorldScence/Interactable/canon_debris.tscn")

@export var shooting : bool
var firerate = 2

@onready var animation_player = $AnimationPlayer
@onready var firepoint = $Firepoint
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

var max_health = 3
var health
var destroyed := false


func _ready() -> void:
	health = max_health
	shooting = true
	shoot()


func shoot():
	while shooting:
		animation_player.play("Fire")
		await get_tree().create_timer(firerate).timeout


func fire():
	if destroyed:
		return
		
	var spawned_ball = cannon_ball.instantiate()
	spawned_ball.direction = firepoint.scale.x
	
	# Add to world FIRST
	get_tree().current_scene.add_child(spawned_ball)
	
	# THEN set global position
	spawned_ball.global_position = firepoint.global_position




func take_damage(damage_amount):
	if destroyed:
		return
		
	health -= damage_amount
	animation_player.play("Hit")
	hit_sound.pitch_scale = randf_range(0.95, 1.05)
	hit_sound.play()
	if health <= 0:
		die()


func die():
	destroyed = true
	shooting = false
	
	var spawned_debris = debris.instantiate()
	
	# Add to world FIRST
	get_tree().current_scene.add_child(spawned_debris)
	death_sound.pitch_scale = randf_range(0.95, 1.05)
	death_sound.play()
	# THEN set correct world position
	spawned_debris.global_position = global_position
	
	visible = false
	collision.disabled = true



# 👇 VERY IMPORTANT
func reset_object():
	destroyed = false
	health = max_health
	shooting = true
	
	visible = true
	collision.disabled = false
	
	shoot()
