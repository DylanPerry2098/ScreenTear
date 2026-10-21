class_name PlayerInput extends Node



func get_horizontal_movement() -> float:
	return Input.get_axis("move_left", "move_right")

func get_vertical_movement() -> float:
	return Input.get_axis("move_up", "move_down")
	
func get_movement_direction() -> Vector2:
	var horiz := Input.get_axis("move_left", "move_right")
	var vert := Input.get_axis("move_up", "move_down")

	return Vector2(horiz, vert).normalized()

func is_face_up() -> bool:
	return Input.is_action_pressed("move_up")
	
func is_face_down() -> bool:
	return Input.is_action_pressed("move_down")

func wants_to_jump() -> bool:
	return Input.is_action_just_pressed("jump")


func wants_to_dialogue() -> bool:
	return Input.is_action_just_pressed("interact")

func flashlight_pressed() -> bool:
	return Input.is_action_just_pressed("turn_off_flashlight")

## Get the mouse's global position in world space
func get_mouse_position() -> Vector2:
	return get_viewport().get_camera_2d().get_global_mouse_position()
