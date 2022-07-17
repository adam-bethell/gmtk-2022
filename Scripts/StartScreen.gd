extends Node2D

signal start_game

var pawn_pos_1 = Vector2(-1, 6)
var pawn_pos_2 = Vector2(8, 6)

var area_entered = false

func _ready():
	$Text/Area2D.connect("mouse_entered", self, "_mouse_entered")
	$Text/Area2D.connect("mouse_exited", self, "_mouse_exited")
	$Text/Area2D.connect("mouse_down", self, "_mouse_down")

func _mouse_entered():
	area_entered = true
	$Text.set_cellv(pawn_pos_1, $Text.get_tileset().find_tile_by_name("White Pawn"))
	$Text.set_cellv(pawn_pos_2, $Text.get_tileset().find_tile_by_name("White Pawn"))
	
func _mouse_exited():
	area_entered = false
	$Text.set_cellv(pawn_pos_1, -1)
	$Text.set_cellv(pawn_pos_2, -1)
	
func _mouse_down():
	if area_entered:
		emit_signal("start_game")
