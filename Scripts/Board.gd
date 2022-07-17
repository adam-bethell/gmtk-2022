extends TileMap

signal turn_complete

var active_unit_prefix = "NULL"
var selected_unit_map_pos = null

func _ready():
	randomize()
	$Area2D.connect("mouse_down", self, "_mouse_down")
	
func set_active_unit_prefix(_active_unit_prefix):
	active_unit_prefix = _active_unit_prefix
	
func _mouse_down():
	
	var mouse_pos = get_local_mouse_position()
	var map_pos = world_to_map (mouse_pos)
	
	var tile_id = $Highlights.get_cellv(map_pos)
	if tile_id != -1:
		take_action(map_pos)
		$Highlights.clear_highlights()
		emit_signal("turn_complete")
	else:
		tile_id = $Pieces.get_cellv(map_pos)
		if tile_id != -1:
			var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
			if tile_name.begins_with(active_unit_prefix):
				show_actions(tile_name, map_pos)
				selected_unit_map_pos = map_pos
		
func is_in_bounds(map_pos):
	if map_pos.x < 0 or map_pos.y < 0 or map_pos.x > 7 or map_pos.y > 7:
		return false
	return true

func show_actions(tile_name, map_pos):
	$Highlights.clear_highlights()
	
	
	$Highlights.show_roll(map_pos)
	
	var data = get_actions(tile_name, map_pos)
	
	assert (data != null)
	for move in data["MOVE"]:
		$Highlights.show_move(move)
	for take in data["TAKE"]:
		$Highlights.show_take(take)
			
func get_actions(tile_name, map_pos):
	var data = null
	if tile_name.ends_with("Pawn"):
		data = get_actions_pawn(map_pos)
	elif tile_name.ends_with("Knight"):
		data = get_actions_knight(map_pos)
	elif tile_name.ends_with("Rook"):
		data = get_actions_rook(map_pos)
	elif tile_name.ends_with("Bishop"):
		data = get_actions_bishop(map_pos)
	elif tile_name.ends_with("Queen"):
		data = get_actions_queen(map_pos)
	elif tile_name.ends_with("King"):
		data = get_actions_king(map_pos)
	
	return data
			
func get_actions_pawn(map_pos):
	var pawn_tile = $Pieces.get_tileset().tile_get_name($Pieces.get_cellv(map_pos))
	
	var data = {}
	data["MOVE"] = []
	data["TAKE"] = []
	
	var move = Vector2(0, -1)
	if active_unit_prefix == "Black":
		move = Vector2(0, 1)
		
	if $Pieces.get_cellv(map_pos + move) == -1 and is_in_bounds(map_pos + move):
		data["MOVE"].push_back(map_pos + move)
		
	var takeA = Vector2(1, -1)
	var takeB = Vector2(-1, -1)
	if active_unit_prefix == "Black":
		takeA = Vector2(-1, 1)
		takeB = Vector2(1, 1)
		
	for take in [takeA, takeB]:
		var tile_id = $Pieces.get_cellv(map_pos + take)
		if tile_id != -1:
			var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
			if (pawn_tile.begins_with("White") and tile_name.begins_with("Black")) or (pawn_tile.begins_with("Black") and tile_name.begins_with("White")):
				data["MOVE"].push_back(map_pos + take)
				
	return data

func get_actions_knight(map_pos):
	var moves = [
		Vector2(-1, -2),
		Vector2(1, -2),
		Vector2(2, -1),
		Vector2(2, 1),
		Vector2(1, 2),
		Vector2(-1, 2),
		Vector2(-2, 1),
		Vector2(-2, -1)
	]
	return get_actions_set(map_pos, moves)
	
func get_actions_rook(map_pos):
	var moves = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1),
	]
	return get_actions_lines(map_pos, moves)
	
func get_actions_bishop(map_pos):
	var moves = [
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1),
	]
	return get_actions_lines(map_pos, moves)

func get_actions_queen(map_pos):
	var moves = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1),
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1),
	]
	return get_actions_lines(map_pos, moves)

func get_actions_king(map_pos):
	var moves = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1),
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1),
	]
	return get_actions_set(map_pos, moves)

func get_actions_lines(map_pos, moves):
	var unit_tile = $Pieces.get_tileset().tile_get_name($Pieces.get_cellv(map_pos))
	
	var data = {}
	data["MOVE"] = []
	data["TAKE"] = []
	
	for move in moves:
		var temp_pos = map_pos
		
		temp_pos += move
		while is_in_bounds(temp_pos):
			var tile_id = $Pieces.get_cellv(temp_pos)
			if tile_id == -1:
				data["MOVE"].push_back(temp_pos)
			else:
				var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
				if (unit_tile.begins_with("White") and tile_name.begins_with("Black")) or (unit_tile.begins_with("Black") and tile_name.begins_with("White")):
					data["TAKE"].push_back(temp_pos)
				break
			temp_pos += move
			
	return data
			
func get_actions_set(map_pos, moves):
	var unit_tile = $Pieces.get_tileset().tile_get_name($Pieces.get_cellv(map_pos))
	
	var data = {}
	data["MOVE"] = []
	data["TAKE"] = []
	
	for move in moves:
		var tile_id = $Pieces.get_cellv(map_pos + move)
		if tile_id == -1 and (map_pos + move):
			data["MOVE"].push_back(map_pos + move)
		elif tile_id != -1:
			var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
			if (unit_tile.begins_with("White") and tile_name.begins_with("Black")) or (unit_tile.begins_with("Black") and tile_name.begins_with("White")):
				data["TAKE"].push_back(map_pos + move)
				
	return data
				
func take_action (map_pos):
	var tile_id = $Highlights.get_cellv(map_pos)
	var tile_name = $Highlights.get_tileset().tile_get_name(tile_id)
	
	if tile_name.ends_with("Take") or tile_name.ends_with("Move"):
		if tile_name.ends_with("Take"):
			$Pieces.set_cellv(map_pos, -1)
		var piece_to_move = $Pieces.get_cellv(selected_unit_map_pos)
		$Pieces.set_cellv(selected_unit_map_pos, -1)
		$Pieces.set_cellv(map_pos, piece_to_move)
	elif tile_name.ends_with("Roll"):
		roll_piece(map_pos)
		
func roll_piece(map_pos):
	var pieces = ["Pawn", "Rook", "Knight", "Bishop", "Queen", "King"]
	pieces.shuffle()
	var new_piece = active_unit_prefix + " " + pieces[0]
	$Pieces.set_cellv(map_pos, get_tileset().find_tile_by_name(new_piece))
		
func get_pieces_count():
	var data = {}
	data["Black"] = 0
	data["White"] = 0
	
	for x in range(8):
		for y in range(8):
			var tile_id = $Pieces.get_cell(x, y)
			if tile_id != -1:
				var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
				if tile_name.begins_with("White"):
					data["White"] = data["White"] + 1
				elif tile_name.begins_with("Black"):
					data["Black"] = data["Black"] + 1
	
	return data
	
func is_player_in_check(player):
	var kings = get_checked_kings()
	for king in kings:
		var tile_id = $Pieces.get_cellv(king)
		var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
		if tile_name.begins_with(player):
			return true
	return false
	
func get_checked_kings():
	var kings_in_check = []
	
	var white_kings = []
	var black_kings = []
	
	for x in range(8):
		for y in range(8):
			var tile_id = $Pieces.get_cell(x, y)
			if tile_id != -1:
				var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
				if tile_name == "White King":
					white_kings.push_back(Vector2(x, y))
				elif tile_name == "Black King":
					black_kings.push_back(Vector2(x, y))
					
	for king in white_kings:
		if is_king_checked(king, "White"):
			kings_in_check.push_back(king)
	for king in black_kings:
		if is_king_checked(king, "Black"):
			kings_in_check.push_back(king)
		
	return kings_in_check
		
func is_king_checked(king, player):
	for x in range(8):
		for y in range(8):
			var map_pos = Vector2(x, y)
			var tile_id = $Pieces.get_cellv(map_pos)
			if tile_id != -1:
				var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
				if not tile_name.begins_with(player):
					var data = get_actions(tile_name, map_pos)
					for take in data["TAKE"]:
						if take == king:
							return true
	return false

