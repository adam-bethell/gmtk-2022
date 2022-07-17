extends Node2D

var current_player = "White"

func _ready():
	$StartScreen.connect("start_game", self, "_start_game")
	$Board.connect("turn_complete", self, "_turn_complete")
	
func _start_game():
	$StartScreen.visible = false
	$Board.visible = true
	$Board.set_active_unit_prefix(current_player)
	
func _turn_complete():
	if $Board.is_player_in_check(current_player):
		# You lose if you're in check at the end of your turn
		game_over()
		return
	
	swap_player()
	var checked_kings = $Board.get_checked_kings()
	$Board/CheckHighlights.clear()
	if checked_kings.size() > 0:
		for pos in checked_kings:
			$Board/CheckHighlights.set_cellv(pos,  $Board/CheckHighlights.get_tileset().find_tile_by_name("Highlight Check"))
		
	$Board.set_active_unit_prefix(current_player)
	
func swap_player():
	if current_player == "White":
		current_player = "Black"
	else:
		current_player = "White"

func game_over():
	$Board.set_active_unit_prefix("VOID")
	if current_player == "White":
		$WinnerScreen/BlackWins.visible = true
	else:
		$WinnerScreen/WhiteWins.visible = true
		
	$WinnerScreen/Checkmate.visible = true
	$WinnerScreen/Restart.visible = true
	
