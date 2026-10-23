class_name CamTransitionArea extends Area2D
## Used to switch between two [CameraPoint]s.

@export var left_cam_point: CameraPoint
@export var right_cam_point: CameraPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	if left_cam_point and right_cam_point:
		if body.global_position.x < global_position.x:
			left_cam_point.focus_camera()
		else:
			right_cam_point.focus_camera()


func _on_body_exited(body: Node) -> void:
	if body is not Player:
		return
	if left_cam_point and right_cam_point:
		if body.global_position.x < global_position.x:
			left_cam_point.focus_camera()
		else:
			right_cam_point.focus_camera()
