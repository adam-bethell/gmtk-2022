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
	var mouse_pos = get_global_mouse_position()
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
	
	if tile_name.ends_with("Pawn"):
		show_actions_pawn(map_pos)
	elif tile_name.ends_with("Knight"):
		show_actions_knight(map_pos)
	elif tile_name.ends_with("Rook"):
		show_actions_rook(map_pos)
	elif tile_name.ends_with("Bishop"):
		show_actions_bishop(map_pos)
	elif tile_name.ends_with("Queen"):
		show_actions_queen(map_pos)
	elif tile_name.ends_with("King"):
		show_actions_king(map_pos)
			
func show_actions_pawn(map_pos):
	var move = Vector2(0, -1)
	if active_unit_prefix == "Black":
		move = Vector2(0, 1)
		
	if $Pieces.get_cellv(map_pos + move) == -1 and is_in_bounds(map_pos + move):
		$Highlights.show_move(map_pos + move)
		
	var takeA = Vector2(1, -1)
	var takeB = Vector2(-1, -1)
	if active_unit_prefix == "Black":
		takeA = Vector2(-1, 1)
		takeB = Vector2(1, 1)
		
	for take in [takeA, takeB]:
		var tile_id = $Pieces.get_cellv(map_pos + take)
		if tile_id != -1:
			var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
			if (active_unit_prefix == "White" and tile_name.begins_with("Black")) or (active_unit_prefix == "Black" and tile_name.begins_with("White")):
				$Highlights.show_take(map_pos + take)

func show_actions_knight(map_pos):
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
	show_actions_set(map_pos, moves)
	
func show_actions_rook(map_pos):
	var moves = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1),
	]
	show_actions_lines(map_pos, moves)
	
func show_actions_bishop(map_pos):
	var moves = [
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
		Vector2(-1, 1),
	]
	show_actions_lines(map_pos, moves)

func show_actions_queen(map_pos):
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
	show_actions_lines(map_pos, moves)

func show_actions_king(map_pos):
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
	show_actions_set(map_pos, moves)

func show_actions_lines(map_pos, moves):
	for move in moves:
		var temp_pos = map_pos
		
		temp_pos += move
		while is_in_bounds(temp_pos):
			var tile_id = $Pieces.get_cellv(temp_pos)
			if tile_id == -1:
				$Highlights.show_move(temp_pos)
			else:
				var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
				if (active_unit_prefix == "White" and tile_name.begins_with("Black")) or (active_unit_prefix == "Black" and tile_name.begins_with("White")):
					$Highlights.show_take(temp_pos)
				break
			temp_pos += move
			
func show_actions_set(map_pos, moves):
	for move in moves:
		var tile_id = $Pieces.get_cellv(map_pos + move)
		if tile_id == -1 and (map_pos + move):
			$Highlights.show_move(map_pos + move)
		elif tile_id != -1:
			var tile_name = $Pieces.get_tileset().tile_get_name(tile_id)
			if (active_unit_prefix == "White" and tile_name.begins_with("Black")) or (active_unit_prefix == "Black" and tile_name.begins_with("White")):
				$Highlights.show_take(map_pos + move)
				
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
	
