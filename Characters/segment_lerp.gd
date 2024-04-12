extends RigidBody2D

@export var prev_node: Node2D

@export var spring_length: float = 50.0

@export var move_speed: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var prev_position = prev_node.position
	var to_prev_vector = prev_position - position  # Vector pointing to the previous node
	var current_distance = to_prev_vector.length()  # Distance to the previous node

	if current_distance > spring_length:
		# Normalize the vector to get direction and multiply by the desired distance
		var direction = to_prev_vector.normalized()
		var target_position = prev_position - direction * spring_length
		
		# Set velocity to move towards the target position
		# You could also use an approach to smoothly interpolate or apply a force
		var move_vector = (target_position - position).normalized() * move_speed
		linear_velocity = move_vector
