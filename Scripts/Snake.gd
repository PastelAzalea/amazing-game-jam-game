extends Node2D
var player = null
var active = true



@export_category("Snake Properties") # You can tweak these changes according to your likings
@export var move_speed : float = 400
@export var jump_force : float = 8
@export var gravity : float = 30
@export var max_jump_count : int = 0
var double_jump = false
var jump_count : int = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $".."

# <-- Player Movement Code -->
func movement():
	if !active:
		return
	player.scale = Vector2(1, 0.1)
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
	if Input.is_action_pressed("Jump"):
		player.position.y -= jump_force

# Player jump
func jump():
	player.jump_tween()
	AudioManager.jump_sfx.play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	movement()

func _on_player_set_active_character(kind):
	if active and kind != "snake":
		player.scale = Vector2(1,1)
		player.position.y -= 40
	active = kind == "snake"
	
