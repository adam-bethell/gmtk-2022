extends Node2D

var current_player = "White"

func _ready():
	$Board.connect("turn_complete", self, "_turn_complete")
	$Board.set_active_unit_prefix(current_player)
	
func _turn_complete():
	if $Board.is_player_in_check(current_player):
		# You lose if you're in check at the end of your turn
		game_over()
		return
		
	if check_winner_ko() == current_player:
		winner()
		return
	
	swap_player()
	if $Board.is_player_in_check(current_player):
		print(current_player + " in check")
	$Board.set_active_unit_prefix(current_player)
	
func swap_player():
	if current_player == "White":
		current_player = "Black"
	else:
		current_player = "White"

func check_winner_ko():
	var data = $Board.get_pieces_count()
	if data["White"] == 0:
		return "Black"
	elif data["Black"] == 0:
		return "White"
	
	return null

func game_over():
	swap_player()
	winner()

func winner():
	$Board.set_active_unit_prefix("VOID")
	print(current_player + " Wins!")
