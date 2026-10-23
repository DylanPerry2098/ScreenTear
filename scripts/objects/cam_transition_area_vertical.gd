class_name CamTransitionAreaVertical extends Area2D
## Used to switch between two [CameraPoint]s.

@export var up_cam_point: CameraPoint
@export var down_cam_point: CameraPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is not Player:
		return
	if up_cam_point and down_cam_point:
		if body.global_position.y < global_position.y:
			up_cam_point.focus_camera()
		else:
			down_cam_point.focus_camera()


func _on_body_exited(body: Node) -> void:
	if body is not Player:
		return
	if up_cam_point and down_cam_point:
		if body.global_position.y < global_position.y:
			up_cam_point.focus_camera()
		else:
			down_cam_point.focus_camera()
