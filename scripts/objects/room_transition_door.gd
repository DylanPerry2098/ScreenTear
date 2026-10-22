class_name RoomTransitionDoor extends Node2D

@export_file("*.tscn") var target_scene:String
var _target_scene_instance: Node

@onready var _area: Area2D = $Area2D
	
func _ready() -> void:

	if Engine.is_editor_hint():
		return
	
	if !target_scene:
		push_error("Transition Area ", name, " has no target scene!")
		return
	var a :PackedScene = load(target_scene)
	_target_scene_instance = a.instantiate()
	_area.body_entered.connect(_on_area_body_entered)

func get_exit_global_pos(player_height: float):
	return global_position + Vector2(0, (144 - player_height))

func _on_area_body_entered(body: Node) -> void:
	if Engine.is_editor_hint() or body is not Player:
		return
	SceneManager.change_scenes_to_path(
		_target_scene_instance,
	)
