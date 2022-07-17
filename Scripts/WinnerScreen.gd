extends Node2D

var area_entered = false

func _ready():
	$Restart/Area2D.connect("mouse_entered", self, "_mouse_entered")
	$Restart/Area2D.connect("mouse_exited", self, "_mouse_exited")
	$Restart/Area2D.connect("mouse_down", self, "_mouse_down")

func _mouse_entered():
	area_entered = true
	$Restart/Hover.visible = true
	
func _mouse_exited():
	area_entered = false
	$Restart/Hover.visible = false
	
func _mouse_down():
	if area_entered:
		get_tree().reload_current_scene()
