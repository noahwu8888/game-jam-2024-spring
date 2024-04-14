extends Node

var game_screen
var back_end
var can_move = false

var win_player: String

var is_moving1 = false
var is_moving2 = false


func end_game():
	game_screen.end_game()
	back_end.respawn()
