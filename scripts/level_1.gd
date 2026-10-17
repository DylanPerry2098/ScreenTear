extends Node2D

@onready var cam: Camera2D = $Camera2D
@onready var cam_trans: Area2D = $CamTransitionArea

func _on_cam_transition_area_body_exited(body: Node2D) -> void:
	if cam_trans.global_position > body.global_position:
		cam.limit_left -= 256
		cam.limit_right -= 256
	else:
		cam.limit_left += 256
		cam.limit_right += 256
