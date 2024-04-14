extends CharacterBody2D


@onready var head_sprite = $HeadSprite
@onready var head = $"."
#Tail and segments
@export var player_num: String = "p1"
@onready var tail_body:RigidBody2D = $"Segment 4/PlayerTail"
var segments = Array()


# Player speed and dash settings
@export var max_speed: float = 400.0  # Maximum speed of the player
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
@onready var reenable_delay_timer:Timer = $"ReenableSegmentTimer"
var reenable_delay_count = 0
var reenable_delay_iterate = false

#sounds
@onready var dig_sound = $Digging

func _ready():
	tail_body.player_num = player_num
	segments.append(self)
	for child in self.get_children():
		if child is RigidBody2D:
			segments.append(child)
		if child.get_child_count() >= 0:
			for subChild in child.get_children():
				if subChild is RigidBody2D:
					segments.append(subChild)
					
		
func _process(delta):
	pass

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	
	if GameManager.can_move:
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
	if(player_num == "p1"):
		if velocity != Vector2.ZERO:
			GameManager.is_moving1 = true
		else:
			GameManager.is_moving1 = false
	elif(player_num == "p2"):
		if velocity != Vector2.ZERO:
			GameManager.is_moving2 = true
		else:
			GameManager.is_moving2 = false
	
	update_facing_direction()
	handle_disable_delay()
	move_and_slide()
	
	# handle_player_2_movement()

	# Check for dash input
	if Input.is_action_just_pressed(player_num + "_dash") and not is_dashing and can_dash:
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
	segments[disable_delay_count].set_collision_layer_value(1, false)
	segments[disable_delay_count].set_collision_mask_value(1, false)
	segments[disable_delay_count].set_collision_mask_value(2, false)
	segments[disable_delay_count].get_child(0).modulate.a = .5
	$Area2D/CollisionShape2D.disabled = true
	
	disable_delay_iterate = true

func handle_disable_delay():
	if disable_delay_iterate:
		if disable_delay_timer.is_stopped():
			disable_delay_timer.start()
	elif reenable_delay_iterate:
		if reenable_delay_timer.is_stopped():
			reenable_delay_timer.start()
			
func update_facing_direction():
	if velocity.length() > 0:  # Ensure there is movement
		head_sprite.rotation = velocity.angle() 



func _on_disable_segment_timer_timeout():
	if disable_delay_count < segments.size():
		print(disable_delay_count)
		segments[disable_delay_count].get_child(0).modulate.a = .5
		segments[disable_delay_count].set_collision_layer_value(1, false)
		segments[disable_delay_count].set_collision_mask_value(1, false)
		segments[disable_delay_count].set_collision_mask_value(2, false)
		disable_delay_count += 1
	else:
		print("Stopped")
		disable_delay_timer.stop()
		disable_delay_count = 0
		disable_delay_iterate = false
		
		
func _on_reenable_segment_timer_timeout():
	if reenable_delay_count < segments.size():
		print(reenable_delay_count)
		segments[reenable_delay_count].get_child(0).modulate.a = 1
		segments[reenable_delay_count].set_collision_layer_value(1, true)
		segments[reenable_delay_count].set_collision_mask_value(1, true)
		segments[reenable_delay_count].set_collision_mask_value(2, true)
		reenable_delay_count += 1
	else:
		print("Stopped")
		$Area2D/CollisionShape2D.disabled = false
		reenable_delay_timer.stop()
		reenable_delay_count = 0
		reenable_delay_iterate = false

func _on_dash_cooldown_timeout():
	can_dash = true







func _on_area_2d_body_entered(body):
	if(body is RigidBody2D and body.get_groups().has("tail")):
		if(body.player_num != player_num):
			print("End Game")
			GameManager.win_player = player_num
			GameManager.end_game()


