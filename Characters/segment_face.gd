extends RigidBody2D

@export var prev_segment:Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Ensure prev_segment is assigned and valid before proceeding
	if prev_segment:
		# Calculate the direction to the prev_segment
		var direction = (prev_segment.position - position).normalized()
		
		# Calculate the angle from current position to the prev_segment
		var angle = direction.angle()
		
		# Set the rotation of this RigidBody2D to the angle
		self.rotation = angle
	else:
		print("prev_segment is not assigned or does not exist.")
