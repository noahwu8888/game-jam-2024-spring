extends Camera2D

# Export variable to set the target node from the editor
@export var target: Node2D


func _ready():
	if target == null:
		print("No target node assigned or node not found.")
	else:
		position = target.global_position # Initialize camera position to target's position

func _process(delta):
	if target != null:
		# Smoothly interpolate the camera's position towards the target's position
		var smooth_speed = 5.0 # Adjust this value to change the smoothing effect
		position = position.lerp(target.global_position, smooth_speed * delta)
