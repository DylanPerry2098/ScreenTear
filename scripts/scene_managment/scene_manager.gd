extends Node
## SceneManager is responsible for managing scene transitions, loading, and unloading scenes throughout the game.

enum GameState {
	DEFAULT, ## Used during normal gameplay.
	PAUSED,	## Used while the game is paused. 
	IN_MENU, ## Currently unused. Will be used for places like the main menu, with all interface and no gameplay.
	DEATH, ## Used when the player dies and while the death animation/cutscene is playing. 
	LOADING_OUT, ## Used when exiting a game scene.
	LOADING_IN, ## Used when loading into a new game scene, either from a menu, from the death screen, or from another room.
}

enum MainScene {
	SAME,
	WORLD,
	ENEMY_TEST,
	MAIN,
	SETTINGS,
	LOAD,
	DIALOGUE,
	HAUNT_ARENA,
	CUTSCENE,
	RESPAWN_ONE,
	RESPAWN_TWO
}

enum UIScene {
	NONE,
	MAIN_UI,
	DEATH
}

enum ScreenTransitionScene {
	NONE,
	FADE,
}

var MAIN_SCENES: Dictionary[MainScene, PackedScene] = {

}

var UI_SCENES: Dictionary[UIScene, PackedScene] = {

}

var SCREEN_TRANSITIONS: Dictionary[ScreenTransitionScene, PackedScene] = {
	ScreenTransitionScene.FADE: preload("res://scenes/screen_transitions/basic_screen_transition.tscn")
}


var current_main_scene: Node ## The currently active main scene (level or menu)

var last_main_scene_resource_uid: int

var current_ui: UserInterface ## The currently active UI scene

var main_scene_stack: Array[Node] = [] ## Stack to hold previous main scenes that can be returned to
var ui_stack: Array[UserInterface] = [] ## Stack to hold previous UI scenes that can be returned to

var is_changing_scenes: bool = false ## Flag to prevent multiple simultaneous scene changes

func _ready():
	current_main_scene = get_tree().get_current_scene()
	if current_main_scene is Level:
		# add UI if starting in a level scene
		current_ui = _new_ui_instance(UIScene.MAIN_UI)
		if current_ui != null:
			get_tree().root.add_child.call_deferred(current_ui)

func get_main_scene() -> Node:
	if current_main_scene:
		return current_main_scene
	var scene := get_tree().current_scene
	if scene:
		return scene
	return get_tree().root

## Returns a new instance of a main scene (level or menu).
func _new_main_scene_instance(new_main_scene_name: MainScene) -> Node:
	if new_main_scene_name == MainScene.SAME:
		return load(current_main_scene.scene_file_path).instantiate()
	if !(new_main_scene_name in MAIN_SCENES.keys()):
		return null
	
	return MAIN_SCENES[new_main_scene_name].instantiate()

## Returns a new instance of a UI scene.
func _new_ui_instance(new_ui_scene_name: UIScene) -> UserInterface:
	if !(new_ui_scene_name in UI_SCENES.keys()):
		return null
	return UI_SCENES[new_ui_scene_name].instantiate()

## Returns a new instance of a transition scene.
func _new_screen_transition_instance(new_screen_transition_name: ScreenTransitionScene) -> ScreenTransition:
	if !(new_screen_transition_name in SCREEN_TRANSITIONS.keys()):
		return null
	return SCREEN_TRANSITIONS[new_screen_transition_name].instantiate()

## Deletes the current main scene if it exists, and replaces it with a new main scene.
func _change_main_scene(new_main_scene: Node, delete: bool):
	last_main_scene_resource_uid = ResourceLoader.get_resource_uid(current_main_scene.scene_file_path)
	if current_main_scene != null:
		get_tree().root.remove_child(current_main_scene)
		if delete:
			current_main_scene.queue_free()
		else:
			main_scene_stack.append(current_main_scene)
	current_main_scene = new_main_scene
	if current_main_scene != null:
		get_tree().root.add_child(current_main_scene)

## Deletes the current UI if it exists, and replaces it with new UI.
func _change_ui(new_ui: UserInterface, delete: bool):
	if current_ui != null:
		get_tree().root.remove_child(current_ui)
		if delete:
			current_ui.queue_free()
		else:
			ui_stack.append(current_ui)
	current_ui = new_ui
	if current_ui != null:
		get_tree().root.add_child(current_ui)

# func reload_current_scene(screen_transition_name: ScreenTransitionScene = ScreenTransitionScene.NONE):
# 	change_scenes(
# 		current_main_scene.name,
# 		current_ui.name if current_ui != null else UIScene.NONE,
# 		screen_transition_name,
# 		true, # Delete old scenes when reloading
# 	)


func change_scenes_to_path(
	new_main_scene: Node,
	new_ui_scene_name: UIScene = UIScene.MAIN_UI,
	screen_transition_name: ScreenTransitionScene = ScreenTransitionScene.NONE,
	delete_old_scenes: bool = true, # Whether to delete the old scenes or push them onto the stack
	) -> void:
	if is_changing_scenes:
		return
	
	is_changing_scenes = true
	# Pause the game during the transition
	get_tree().paused = true


	var new_ui_scene: UserInterface = _new_ui_instance(new_ui_scene_name)
	
	
	var screen_transition: ScreenTransition = _new_screen_transition_instance(screen_transition_name)

	
	
	# Fade in
	if screen_transition != null:
		get_tree().root.add_child(screen_transition)
		screen_transition.fade_in()
		await screen_transition.fade_in_finished
	
	# Change scenes
	_change_main_scene(new_main_scene, delete_old_scenes)
	_change_ui(new_ui_scene, delete_old_scenes)
	
	
	# Fade out
	if screen_transition != null:
		screen_transition.fade_out()
		await screen_transition.fade_out_finished
		screen_transition.queue_free()
	
	get_tree().paused = false
	is_changing_scenes = false



## Changes the main scene and UI to new scenes, optionally using a screen transition.
func change_scenes(
	new_main_scene_name: MainScene,
	new_ui_scene_name: UIScene = UIScene.NONE,
	screen_transition_name: ScreenTransitionScene = ScreenTransitionScene.NONE,
	delete_old_scenes: bool = true, # Whether to delete the old scenes or push them onto the stack
	):
	if is_changing_scenes:
		return
	
	is_changing_scenes = true
	# Pause the game during the transition
	get_tree().paused = true

	var new_main_scene: Node

	# Create new instances of the scenes
	new_main_scene = _new_main_scene_instance(new_main_scene_name)
	
	var new_ui_scene: UserInterface = _new_ui_instance(new_ui_scene_name)
	var screen_transition: ScreenTransition = _new_screen_transition_instance(screen_transition_name)
	
	# Save new scene to Save Manager
	#if new_main_scene_name != 2 and new_main_scene_name != 3 and new_main_scene_name != 5:
		#SaveInfo.current_scene = new_main_scene_name
		#SaveManager.save_game(SaveInfo.current_slot)
	
	# Fade in
	if screen_transition != null:
		get_tree().root.add_child(screen_transition)
		screen_transition.fade_in()
		await screen_transition.fade_in_finished
	
	# Change scenes
	_change_main_scene(new_main_scene, delete_old_scenes)
	_change_ui(new_ui_scene, delete_old_scenes)

	# Fade out
	if screen_transition != null:
		screen_transition.fade_out()
		await screen_transition.fade_out_finished
		screen_transition.queue_free()
	
	get_tree().paused = false
	is_changing_scenes = false

## Pops the last main scene and UI from their respective stacks and makes them the current scenes.
func pop_stacked_scenes(screen_transition_name: ScreenTransitionScene = ScreenTransitionScene.NONE):
	if is_changing_scenes or (main_scene_stack.size() == 0 and ui_stack.size() == 0):
		return
	
	is_changing_scenes = true
	# Pause the game during the transition
	get_tree().paused = true
	
	var previous_main_scene: Node = null
	var previous_ui_scene: UserInterface = null
	var screen_transition: ScreenTransition = _new_screen_transition_instance(screen_transition_name)
	
	if main_scene_stack.size() > 0:
		previous_main_scene = main_scene_stack.pop_back()
	if ui_stack.size() > 0:
		previous_ui_scene = ui_stack.pop_back()
	
	# Fade in
	if screen_transition != null:
		get_tree().root.add_child(screen_transition)
		screen_transition.fade_in()
		await screen_transition.fade_in_finished
	
	# Change scenes
	_change_main_scene(previous_main_scene, true)
	_change_ui(previous_ui_scene, true)

	# Fade out
	if screen_transition != null:
		screen_transition.fade_out()
		await screen_transition.fade_out_finished
		screen_transition.queue_free()
	

	get_tree().paused = false
	is_changing_scenes = false
