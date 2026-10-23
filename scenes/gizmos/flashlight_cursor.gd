class_name FlashlightCursor extends Node2D

@onready var cursor: Sprite2D = %Cursor
@onready var spotlight: PointLight2D = %Spotlight


func _ready() -> void:
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func toggle_spotlight_mode(enabled: bool) -> void:
	cursor.visible = !enabled
	spotlight.visible = enabled

func _physics_process(_delta: float) -> void:
	global_position = get_viewport().get_mouse_position()
