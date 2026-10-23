@tool
class_name RoomTransitionArea2D extends Area2D

@export_file("*.tscn") var target_scene:String

const FIXED_THICKNESS := 8.0

const EXIT_DISTANCE := 16.0

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var direction: Direction = Direction.RIGHT:
	set(value):
		_direction = value
		_apply_editor_configuration()
	get:
		return _direction

## The size of the transition area along its active axis.
@export var size := 16.0:
	set(value):
		_size = max(value, 1.0)
		_apply_editor_configuration()
	get:
		return _size

var _direction: Direction = Direction.RIGHT
var _size := 16.0

var _has_unique_collision_shapes := false

@onready var _color_rect: ColorRect = $ColorRect
@onready var _area_collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _body_collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

var _target_scene_instance: Node

func _ready() -> void:
	_ensure_unique_collision_shapes()
	_apply_editor_configuration()

	if Engine.is_editor_hint():
		return
	
	if !target_scene:
		push_error("Transition Area ", name, " has no target scene!")
		return
	var a :PackedScene = load(target_scene)
	_target_scene_instance = a.instantiate()

	body_entered.connect(_on_body_entered)


func _apply_editor_configuration() -> void:
	if not is_node_ready():
		return

	_apply_shape_configuration()


func _apply_shape_configuration() -> void:
	_ensure_unique_collision_shapes()

	var transition_size: Vector2
	match _direction:
		Direction.UP, Direction.DOWN:
			transition_size = Vector2(_size, FIXED_THICKNESS)
		Direction.LEFT, Direction.RIGHT:
			transition_size = Vector2(FIXED_THICKNESS, _size)

	_color_rect.offset_left = -transition_size.x * 0.5
	_color_rect.offset_top = -transition_size.y * 0.5
	_color_rect.offset_right = transition_size.x * 0.5
	_color_rect.offset_bottom = transition_size.y * 0.5

	var area_shape := _area_collision_shape.shape as RectangleShape2D
	if area_shape != null:
		area_shape.size = transition_size

	_area_collision_shape.position = Vector2.ZERO

	var body_shape := _body_collision_shape.shape as SegmentShape2D
	if body_shape != null:
		var half_width := transition_size.x * 0.5
		var half_height := transition_size.y * 0.5
		match _direction:
			Direction.UP:
				body_shape.a = Vector2(-half_width, -half_height)
				body_shape.b = Vector2(half_width, -half_height)
			Direction.DOWN:
				body_shape.a = Vector2(-half_width, half_height)
				body_shape.b = Vector2(half_width, half_height)
			Direction.LEFT:
				body_shape.a = Vector2(-half_width, -half_height)
				body_shape.b = Vector2(-half_width, half_height)
			Direction.RIGHT:
				body_shape.a = Vector2(half_width, -half_height)
				body_shape.b = Vector2(half_width, half_height)

## Find the exit position for the player assuming they enter the room from this transition area. Place them floor if possible, using their height as a reference.
func get_exit_global_pos(player_height: float) -> Vector2:
	match _direction:
		Direction.UP:
			return global_position + Vector2(0, EXIT_DISTANCE)
		Direction.DOWN:
			return global_position + Vector2(0, -EXIT_DISTANCE * 2)
		Direction.LEFT:
			return global_position + Vector2(EXIT_DISTANCE, ((size/2)-(player_height) - 1))
		Direction.RIGHT:
			return global_position + Vector2(-EXIT_DISTANCE, ((size/2)-(player_height) - 1))
	return global_position

func _ensure_unique_collision_shapes() -> void:
	if _has_unique_collision_shapes:
		return
	if not is_node_ready():
		return

	if _area_collision_shape.shape == null:
		_area_collision_shape.shape = RectangleShape2D.new()
	else:
		_area_collision_shape.shape = _area_collision_shape.shape.duplicate(true)
	_area_collision_shape.shape.resource_local_to_scene = true

	if _body_collision_shape.shape == null:
		_body_collision_shape.shape = SegmentShape2D.new()
	else:
		_body_collision_shape.shape = _body_collision_shape.shape.duplicate(true)
	_body_collision_shape.shape.resource_local_to_scene = true

	_has_unique_collision_shapes = true

func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	if body is Player:
		SceneManager.change_scenes_to_path(
			_target_scene_instance,
			SceneManager.UIScene.NONE,
			SceneManager.ScreenTransitionScene.FADE,
		)
	else:
		push_error("Body other than player detected by RoomTransitionArea2D ", name)
