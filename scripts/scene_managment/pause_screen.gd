extends CanvasLayer

@onready var menu = $PauseScreen
var paused := false

var target_scene := "res://scenes/levels/main_menu.tscn"
var _target_scene_instance: Node

func _ready() -> void:
	var a: PackedScene = load(target_scene)
	_target_scene_instance = a.instantiate()

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
	SceneManager.change_scenes_to_path(_target_scene_instance)


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else 
		DisplayServer.WINDOW_MODE_WINDOWED)
