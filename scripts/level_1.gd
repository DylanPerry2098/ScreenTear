extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var cam_trans: Area2D = $CameraTransitions/CamTransitionArea1
@onready var cam_trans2: Area2D = $CameraTransitions/CamTransitionArea2


#Camera transitions do not work if combined into the same function
func _on_cam_transition1_area_body_exited(body: Node2D) -> void:
	if cam_trans.global_position < body.global_position:
		move_cam_right()
	else:
		move_cam_left()

func _on_cam_transition2_area_body_exited(body: Node2D) -> void:
	if cam_trans2.global_position < body.global_position:
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
