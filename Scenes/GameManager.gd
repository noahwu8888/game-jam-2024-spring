extends Node

var game_screen
var back_end
var can_move = false

var win_player: String



func end_game():
	game_screen.end_game()
	back_end.respawn()
