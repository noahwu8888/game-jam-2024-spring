extends RigidBody2D

# Player speed and dash settings
@export var max_speed: float = 700.0  # Maximum speed of the player


# Drag and acceleration settings
@export var stop_drag: float = 2.0  # How quickly the player stops when no input is given
@export var max_acceleration: float = 3000.0  # Maximum rate of acceleration

# Internal variables for movement and dashing
var player_num: String

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	
	# Getting the directional input from the player
	if GameManager.can_move:
		input_vector.x = Input.get_action_strength(player_num + "_move_right2") - Input.get_action_strength(player_num + "_move_left2")
		input_vector.y = Input.get_action_strength(player_num + "_move_down2") - Input.get_action_strength(player_num + "_move_up2")
		input_vector = input_vector.normalized()

	# Calculate target velocity based on input direction
	var target_velocity = input_vector * max_speed

	# Calculate acceleration vector needed to move towards target velocity
	var velocity_change = target_velocity - linear_velocity
	var acceleration_vector = Vector2.ZERO  # Initialize acceleration vector

	# Check if the magnitude of the velocity change is greater than the allowed maximum acceleration
	if velocity_change.length() > max_acceleration * delta:
		# If it is greater, limit the acceleration to the maximum allowed, preserving the direction
		acceleration_vector = velocity_change.normalized() * max_acceleration * delta
	else:
		# Otherwise, use the velocity change as is
		acceleration_vector = velocity_change



	# Apply acceleration to linear velocity
	linear_velocity += acceleration_vector

	# Apply stop drag if not moving
	if input_vector == Vector2.ZERO and linear_velocity.length() > 0:
		linear_velocity = linear_velocity.move_toward(Vector2.ZERO, stop_drag * delta)
		

