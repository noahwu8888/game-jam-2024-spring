extends Node

@onready var game_screen = $HBoxContainer

@onready var title_screen = $TitleScreen
@onready var button = $TitleScreen/Button

@onready var game_over_screen = $GameOverScreen
@onready var win_text = $GameOverScreen/Label

@onready var players := {
	"1": {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Node2D/Player1,
	},
	
	"2": {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Node2D/Player2,
	}
}
# Called when the node enters the scene tree for the first time.
func _ready():
	players["2"].viewport.world_2d = players["1"].viewport.world_2d
	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
	
	# Push items to GameManager
	GameManager.game_screen = self
	
func start_game():
	title_screen.visible = false
	game_screen.visible = true
	GameManager.can_move = true
func end_game():
	game_over_screen.visible = true
	win_text.text = "Game Over, " + GameManager.win_player + " wins!"
	game_screen.visible = false
	GameManager.can_move = false

func _on_start_button_pressed():
	start_game()



func _on_restart_button_pressed():
	get_tree().reload_current_scene()
