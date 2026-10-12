@tool
class_name RoomTransitionDoor extends Node2D

@export_file("*.tscn") var target_scene:String
var _target_scene_instance: Node

@export var in_foreground := false:
	set(x):
		in_foreground = x
		$ColorRect.color.a = 0.5 if in_foreground else 1.0
		z_index = 10 if in_foreground else 0
	
func _ready() -> void:

	if Engine.is_editor_hint():
		return
	
	if !target_scene:
		push_error("Transition Area ", name, " has no target scene!")
		return
	var a :PackedScene = load(target_scene)
	_target_scene_instance = a.instantiate()

	%Interactible.interacted.connect(_on_interact)

func get_exit_global_pos(player_height: float):
	return global_position + Vector2(0, (144 - player_height))

func _on_interact():
	if Engine.is_editor_hint():
		return
	SceneManager.change_scenes_to_path(
		_target_scene_instance,
		SceneManager.UIScene.NONE,
		SceneManager.ScreenTransitionScene.FADE,
	)
