extends Sprite2D


func _physics_process(_delta: float) -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	global_position = get_viewport().get_mouse_position()