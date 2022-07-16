extends Node2D

enum {WHITE, BLACK}

var current_player = WHITE
var in_check = false

func _ready():
	$Board.connect("turn_complete", self, "_turn_complete")
	board_set_active_player()
	
func _turn_complete():
	var result = check_check()
	if result == null:
		swap_player()
		board_set_active_player()
	else:
		pass
	
func swap_player():
	if current_player == WHITE:
		current_player = BLACK
	else:
		current_player = WHITE
		
func board_set_active_player():
	if current_player == WHITE:
		$Board.set_active_unit_prefix("White")
	else:
		$Board.set_active_unit_prefix("Black")

func check_check():
	var data = $Board.get_checked_kings()

func check_winner():
	var result = check_winner_ko()
	if result != null:
		return result
	
func check_winner_ko():
	var data = $Board.get_pieces_count()
	if data["White"] == 0:
		return "Black"
	elif data["Black"] == 0:
		return "White"
	
	return null
