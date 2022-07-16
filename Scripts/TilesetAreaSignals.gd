extends Area2D

signal mouse_down

func _process(_delta):
	if Input.is_action_just_pressed("click"):
		emit_signal("mouse_down")
	
