class_name NPCPlayer extends Node2D

signal desired_mouse_hovers_reached

var mouse_over_count := 0
var desired_mouse_hovers := 0
var _mouse_is_over := false
var _desired_hovers_reached := false

var current_mouse_position := Vector2.ZERO
var _hover_bounding_box := Rect2()

@onready var hover_shape: CollisionShape2D = %HoverShape

func _ready() -> void:
	_hover_bounding_box = hover_shape.shape.get_rect()

func _physics_process(_delta: float) -> void:
	current_mouse_position = get_global_mouse_position()

	var mouse_is_over := _hover_bounding_box.has_point(
		hover_shape.to_local(current_mouse_position)
	)
	if mouse_is_over and not _mouse_is_over:
		mouse_over_count += 1
		if desired_mouse_hovers > 0 and mouse_over_count >= desired_mouse_hovers and not _desired_hovers_reached:
			_desired_hovers_reached = true
			desired_mouse_hovers_reached.emit()

	_mouse_is_over = mouse_is_over
