extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var cam_trans: Area2D = $CameraTransitions/CamTransitionArea


func _on_cam_transition1_area_body_exited(body: Node2D) -> void:
	if cam_trans.global_position < body.global_position:
		move_cam_right()
	else:
		move_cam_left()

func move_cam_left() -> void:
	#Subtract 256 from left and right limits of camera
	cam.limit_left -= 256
	cam.limit_right -= 256

func move_cam_right() -> void:
	#Add 256 to left and right limits of camera
	cam.limit_left += 256
	cam.limit_right += 256
