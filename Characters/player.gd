extends CharacterBody2D

#Tail and segments
@export var player_num: String = "p1"
@onready var tail_body:RigidBody2D = $"Segment 4/PlayerTail"
var segments = Array()


# Player speed and dash settings
@export var max_speed: float = 200.0  # Maximum speed of the player
@export var dash_speed: float = 1500.0  # Initial speed of the dash
@export var dash_control: float = 20.0

@onready var dash_cooldown:Timer = $"DashCooldown"
var can_dash = true

# Drag settings
@export var dash_drag: float = 30.0  # How quickly the player slows down from a dash to max speed
@export var stop_drag: float = 10.0  # How quickly the player stops when no input is given

# Internal variables for movement and dashing
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO

@onready var disable_delay_timer:Timer = $"DisableSegmentTimer"
var disable_delay_count = 0
var disable_delay_iterate = false
var reenable_delay_iterate = false

func _ready():
	tail_body.player_num = player_num
	
	
	for child in self.get_children():
		if child is CollisionShape2D:
			segments.append(child)
		if child.get_child_count() >= 0:
			for subChild in child.get_children():
				for subSubChild in subChild.get_children():
					if subSubChild is CollisionShape2D:
						segments.append(subSubChild)


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
			reenable_delay_iterate = true
			


	handle_disable_delay()
	move_and_slide()
	
	# handle_player_2_movement()

	# Check for dash input
	if Input.is_action_just_pressed("ui_accept") and not is_dashing and can_dash:
		start_dash(input_vector)
		dash_cooldown.start()

func start_dash(direction: Vector2):
	can_dash = false
	if direction.length() > 0:
		dash_direction = direction
	else:
		dash_direction = velocity.normalized() if velocity.length() > 0 else Vector2.RIGHT
	is_dashing = true
	velocity = dash_direction * dash_speed
	
	## disable all collision
	#for child in segments:
		#child.disabled = true
	disable_delay_iterate = true

func handle_disable_delay():
	if disable_delay_iterate || reenable_delay_iterate:
		if disable_delay_timer.is_stopped():
			disable_delay_timer.start()
	elif reenable_delay_iterate:
		pass



func _on_disable_segment_timer_timeout():
	if disable_delay_count < segments.size():
		print(disable_delay_count)
		segments[disable_delay_count].disabled = !segments[disable_delay_count].disabled
		disable_delay_count += 1
	else:
		print("Stopped")
		disable_delay_timer.stop()
		disable_delay_count = 0
		disable_delay_iterate = false
		reenable_delay_iterate = false
		


func _on_dash_cooldown_timeout():
	can_dash = true
