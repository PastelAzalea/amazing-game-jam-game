extends Node2D

var player = null
var active = false

@export_category("Frog Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 600
@export var gravity : float = 30
@export var max_jump_count : int = 2

var jump_step = 500
var current_jump_step = 0
var max_jump_step = 700

var double_jump = false
var jump_count : int = 2

# --------- BUILT-IN FUNCTIONS ---------- #

func _ready():
	player = $".."

func _process(delta):
	if !active:
		return
	# Calling functions
	movement(delta)

# --------- CUSTOM FUNCTIONS ---------- #

# <-- Player Movement Code -->
func movement(delta):
	# Gravity
	if !player.is_on_floor():
		player.velocity.y += gravity
	elif player.is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping(delta)
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	player.velocity = Vector2(inputAxis * move_speed, player.velocity.y)
	player.move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping(delta):
	if Input.is_key_pressed(KEY_SPACE):
		player.scale = Vector2(1, 0.6)
		current_jump_step += delta*jump_step
		move_speed = 0
	elif current_jump_step > 0:
		if player.is_on_floor() and !double_jump:
			jump()
		elif double_jump and jump_count > 0:
			jump()
			jump_count -= 1

# Player jump
func jump():
	player.velocity.y = -(jump_force + min(current_jump_step, max_jump_step))
	current_jump_step = 0
	move_speed = 400
	player.scale = Vector2(1, 1)

# --------- SIGNALS ---------- #

func _on_player_set_active_character(kind):
	active = kind == "frog"
