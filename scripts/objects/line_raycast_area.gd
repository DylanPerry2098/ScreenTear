class_name LineRaycastArea extends Area2D

@onready var raycast: RayCast2D = $RayCast2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var segment: SegmentShape2D
var length := 128.0

func _ready() -> void:
	segment = SegmentShape2D.new()
	collision_shape.shape = segment
	segment.a = Vector2.ZERO
	set_length(length)


func set_length(length: float) -> void:
	self.length = maxf(length, 0.0)
	if not segment:
		return
	segment.b = Vector2(self.length, 0)
	raycast.target_position = Vector2(self.length, 0)

func _physics_process(_delta: float) -> void:
	_update_segment()

func _update_segment() -> void:
	raycast.force_raycast_update()
	var end_position := Vector2(self.length, 0)
	if raycast.is_colliding():
		end_position.x = clampf(to_local(raycast.get_collision_point()).x, 0.0, self.length)
	segment.b = end_position

func get_segment_global_endpoints() -> Array[Vector2]:
	_update_segment()
	return [
		global_position,
		to_global(segment.b)
	]
