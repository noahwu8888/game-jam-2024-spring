extends Node

var game_screen
var back_end
var can_move = false



func end_game():
	game_screen.end_game()
	back_end.respawn()
