extends CanvasLayer

@onready var menu = $PauseScreen
var paused := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()
	pass

func _toggle_pause():
	if paused:
		menu.hide()
		get_tree().paused = false
	else:
		menu.show()
		get_tree().paused = true
		
	paused = !paused


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else 
		DisplayServer.WINDOW_MODE_WINDOWED)
