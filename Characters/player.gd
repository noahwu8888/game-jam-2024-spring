extends CharacterBody2D

@export var player_num: String = "p1"
@onready var tail_body:RigidBody2D = $"Segment 4/PlayerTail"
# Player speed and dash settings
@export var max_speed: float = 200.0  # Maximum speed of the player
@export var dash_speed: float = 1000.0  # Initial speed of the dash
@export var dash_control: float = 10.0



# Drag settings
@export var dash_drag: float = 20.0  # How quickly the player slows down from a dash to max speed
@export var stop_drag: float = 10.0  # How quickly the player stops when no input is given

# Internal variables for movement and dashing
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO

func _ready():
	tail_body.player_num = player_num

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength(player_num + "_move_right") - Input.get_action_strength(player_num + "_move_left")
	input_vector.y = Input.get_action_strength(player_num + "_move_down") - Input.get_action_strength(player_num + "_move_up")
	input_vector = input_vector.normalized()

		# Apply stop drag if not moving
	if not is_dashing:
		if input_vector == Vector2.ZERO and velocity.length() > 0:
			velocity = velocity.move_toward(Vector2.ZERO, stop_drag)
		else:
			velocity = input_vector * max_speed

	# Apply dash drag if dashing
	# Inside your _physics_process function
	if is_dashing:
		# Calculate the velocity component in the direction of the dash
		var velocity_in_dash_direction: float = velocity.dot(dash_direction.normalized())

		# Apply dash drag and add control for perpendicular movement
		var projection: Vector2 = (dash_direction.dot(input_vector) / dash_direction.length_squared()) * dash_direction
		var perpendicular_input: Vector2 = input_vector - projection
		velocity = velocity.move_toward(velocity.normalized() * max_speed, dash_drag) + (perpendicular_input * dash_control)

		# Check if the component of the velocity in the dash direction is less than or equal to max_speed
		if velocity_in_dash_direction <= max_speed:
			is_dashing = false  # Stop dashing once the component of velocity in dash direction is at or below max_speed


	move_and_slide()
	
	# handle_player_2_movement()

	# Check for dash input
	if Input.is_action_just_pressed("ui_accept") and not is_dashing:  # Assuming 'ui_accept' is mapped to Space
		start_dash(input_vector)

func start_dash(direction: Vector2) -> void:
	if direction.length() > 0:
		dash_direction = direction
	else:
		dash_direction = velocity.normalized() if velocity.length() > 0 else Vector2.RIGHT
	is_dashing = true
	velocity = dash_direction * dash_speed


#func handle_player_2_movement():
	#var input_vector: Vector2 = Vector2.ZERO
	#
	#input_vector.x = Input.get_action_strength("move_right2") - Input.get_action_strength("move_left2")
	#input_vector.y = Input.get_action_strength("move_down2") - Input.get_action_strength("move_up2")
	#input_vector = input_vector.normalized()
#
		## Apply stop drag if not moving
#
	#if input_vector == Vector2.ZERO and velocity.length() > 0:
		#tail_body.velocity = velocity.move_toward(Vector2.ZERO, stop_drag)
	#else:
		#tail_body.velocity = input_vector * max_speed
