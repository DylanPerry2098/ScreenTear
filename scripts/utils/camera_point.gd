class_name CameraPoint extends Node2D
## Defines a point in the game world where the camera should focus when the player enters a specific area. Used by [CamTransitionArea] to switch between camera points.


func ensure_camera() -> Camera2D:
	var cam: Camera2D = get_viewport().get_camera_2d()
	if not cam:
		cam = Camera2D.new()
		get_viewport().add_child(cam)
	return cam

func focus_camera() -> void:
	var cam: Camera2D = ensure_camera()
	if cam: cam.global_position = global_position