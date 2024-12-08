extends Node2D
var player = null
var active = false
var is_in_water = false
var is_in_tree = false
@export_category("Lizard Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 1400
@export var jump_force : float = 600
@export var gravity : float = 30
@export var max_jump_count : int = 2
var double_jump = false
var jump_count : int = 2
var water_duration = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $".."


# <-- Player Movement Code -->
func movement(delta):
	if !active:
		return
	if is_in_water:
		water_duration -= delta
		if water_duration < 0:
			player.death_tween()
			water_duration = 1
			is_in_water = false
			
	# Gravity
	if !player.is_on_floor():
		player.velocity.y += gravity
	elif player.is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	if !is_in_tree:
		player.velocity = Vector2(inputAxis * move_speed, player.velocity.y)
	else:
		player.velocity = Vector2(0, -inputAxis * move_speed)
	player.move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		if player.is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	player.jump_tween()
	AudioManager.jump_sfx.play()
	player.velocity.y = -jump_force



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movement(delta)

func _on_player_set_active_character(kind):
	active = kind == "lizard"


func _on_player_set_in_water_flag(player_is_in_water):
	is_in_water = player_is_in_water
	if is_in_water:
		gravity = 0.1
		player.velocity.y = 0
		move_speed = 700
	else:
		move_speed = 1400
		gravity = 30
		jump_force = 600
		water_duration = 1


func _on_player_set_in_tree_flag(player_is_in_tree: Variant) -> void:
	if !active:
		return
	is_in_tree = player_is_in_tree
	if is_in_tree:
		player.rotation = -90.0
		player.velocity.y = 0
		move_speed = 700
	else:
		player.rotation = 0
		move_speed = 1400
		gravity = 30
		jump_force = 600
		water_duration = 1
