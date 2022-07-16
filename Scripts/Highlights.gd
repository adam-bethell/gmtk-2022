extends TileMap

func show_move(map_pos):
	set_cellv(map_pos, get_tileset().find_tile_by_name("Highlight Move"))
	
func show_take(map_pos):
	set_cellv(map_pos, get_tileset().find_tile_by_name("Highlight Take"))

func show_roll(map_pos):
	set_cellv(map_pos, get_tileset().find_tile_by_name("Highlight Roll"))
	
func clear_highlights():
	clear()
