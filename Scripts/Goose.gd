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
func movement(delta):
	# Gravity
	if !player.is_on_floor():
		player.velocity.y += gravity
	elif player.is_on_floor():
		jump_count = max_jump_count
	
	handle_jumping()
	
	# Move Player
	if player.is_on_floor():
		var inputAxis = Input.get_axis("Left", "Right")
		player.velocity = Vector2(inputAxis * move_speed, player.velocity.y)
	else:
		var inputAxis = Input.get_axis("Left", "Right")
		player.velocity = Vector2(inputAxis * move_speed * 0.5, player.velocity.y)
		# I actually had AI code proper Air resistance for me for this bird. Feels somehow very cool to play
		# I wish though we could set terminal velocity and time to that velocity directly. My physics is very rusty on this and I am lazy right now
		# And lastly the drag force enables some gliding mechanic that I didnt manage to  make realistic also because of lacking physics i guess
		# Calculate the drag force (F_d)
		var drag_force_magnitude = 0.5 * 1.2 * 0.5 * 0.05 * player.velocity.length() * player.velocity.length()
		# Calculate the drag force vector (opposite to velocity)
		var drag_force = player.velocity.normalized() * -drag_force_magnitude
		# Apply the drag force (Newton's second law: F = ma)
		var mass = 2
		var acceleration = drag_force / mass
		player.velocity += acceleration * delta 
		
		
	player.move_and_slide()

# Handles jumping functionality (double jump or single jump, can be toggled from inspector)
func handle_jumping():
	if Input.is_action_just_pressed("Jump"):
		jump()

# Player jump
func jump():
	player.jump_tween()
	AudioManager.jump_sfx.play()
	player.velocity.y = -jump_force
	var inputAxis = Input.get_axis("Left", "Right")
	player.velocity += Vector2(inputAxis * move_speed * 0.5, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
	movement(delta)

func _on_player_set_active_character(kind):
	active = kind == "goose"


func _on_player_set_in_water_flag(player_is_in_water: Variant) -> void:
	if active:
		player.death_tween()
