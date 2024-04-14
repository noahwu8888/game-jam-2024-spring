extends Node2D

@onready var p1 = $Player1
@onready var p2 = $Player2

var p1_spawn
var p2_spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.back_end = self
	p1_spawn = p1.global_position
	p2_spawn = p2.global_position

func respawn():
	p1.global_position = p1_spawn
	p2.global_position = p2_spawn
	for child in p1.get_children():
		if child is RigidBody2D:
			child.global_position = p1_spawn
	for child in p2.get_children():
		if child is RigidBody2D:
			child.global_position = p2_spawn

