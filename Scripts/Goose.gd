extends Node2D

var player = null
var active = false

@export_category("Gooose Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 400
@export var gravity : float = 7
@export var max_jump_count : int = 2

var double_jump = false
var jump_count : int = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $".."


# <-- Player Movement Code -->
func movement():
	# Gravity
	if !player.is_on_floor():
		player.velocity.y += gravity
	elif player.is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping()
	
	# Move Player
	var inputAxis = Input.get_axis("Left", "Right")
	player.velocity = Vector2(inputAxis * move_speed, player.velocity.y)
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
	if !active:
		return
	movement()

func _on_player_set_active_character(kind):
	active = kind == "goose"
