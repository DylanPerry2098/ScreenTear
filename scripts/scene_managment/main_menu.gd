extends Control

@export var credit_screen: Control
@export_file("*.tscn") var target_scene: String
var _target_scene_instance: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !credit_screen:
		push_error("No Attached Credit Screen On " + self.name)
		return
		
	if !target_scene:
		push_error("No Attached Start Level On " + self.name)
		return
	var a: PackedScene = load(target_scene)
	_target_scene_instance = a.instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _toggle_credit_screen(bl: bool) -> void:
	if credit_screen:
		credit_screen.visible = bl


func _on_play_button_pressed() -> void:
	SceneManager.change_scenes_to_path(_target_scene_instance)


func _on_credits_button_pressed() -> void:
	_toggle_credit_screen(true)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credit_close_button_pressed() -> void:
	_toggle_credit_screen(false)
