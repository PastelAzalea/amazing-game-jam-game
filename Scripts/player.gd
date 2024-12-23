extends CharacterBody2D

signal set_active_character(character)
var active_character = "frog"
var character_keys = {
	KEY_1: "frog",
	KEY_2: "lizard",
	KEY_3: "snake",
	KEY_4: "platypus",
	KEY_5: "goose",
}

signal set_in_water_flag(player_is_in_water)
signal set_in_tree_flag(player_is_in_tree)
# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 600
@export var gravity : float = 30
@export var max_jump_count : int = 2
var jump_count : int = 2

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
@export var double_jump : = false

var is_grounded : bool = false

@onready var player_sprite = $FrogSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles

# --------- BUILT-IN FUNCTIONS ---------- #
func _ready():
	set_sprite()
	

func _process(_delta):
	# Calling functions
	set_active_animal()
	player_animations()
	flip_player()
	
# --------- CUSTOM FUNCTIONS ---------- #
func set_sprite():
	match active_character:
		"lizard": player_sprite = $LizardSprite2D
		"goose": player_sprite = $GooseSprite2D
		"frog": player_sprite = $FrogSprite2D
		"snake": player_sprite = $SnakeSprite2D
		_: player_sprite = $AnimatedSprite2D
	set_active_character.emit(active_character)
	var allsprites =[$LizardSprite2D,$AnimatedSprite2D,$GooseSprite2D, $FrogSprite2D, $SnakeSprite2D]
	for sprite in allsprites:
		sprite.visible = sprite==player_sprite

func set_active_animal():
	var current_character = active_character
	for key in character_keys:
		var character = character_keys[key]
		if Input.is_key_pressed(key):
			active_character = character
	if current_character != active_character:
		set_sprite()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	jump_tween()
	AudioManager.jump_sfx.play()
	velocity.y = -jump_force

# Handle Player Animations
func player_animations():
	particle_trails.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("Walk", 1.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0: 
		player_sprite.flip_h = true
	elif velocity.x > 0:
		player_sprite.flip_h = false

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	self.velocity = Vector2(0,0)
	await get_tree().create_timer(0.3).timeout
	self.position.y += -100
	AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
func _on_collision_body_entered(_body):
	if _body.is_in_group("Traps"):
		AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()


func _on_area_2d_body_entered(_body):
	if _body.is_in_group("Water"):
		set_in_water_flag.emit(true)
	if _body.is_in_group("Trees"):
		set_in_tree_flag.emit(true)

func _on_area_2d_body_exited(_body):
	if _body.is_in_group("Water"):
		set_in_water_flag.emit(false)
	if _body.is_in_group("Trees"):
		set_in_tree_flag.emit(false)
