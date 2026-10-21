extends StaticBody2D

var plate_pressed := false

@onready var sprite_2d = $Sprite2D

@export var area_2d: Area2D
@export var connected_obj: ToggleableObject


const TEXTURE_UNPRESSED = preload("res://assets/plate_unpressed.png")
const TEXTURE_PRESSED = preload("res://assets/plate_pressed.png")
	
func _ready() -> void:
	plate_pressed = false
	sprite_2d.texture = TEXTURE_UNPRESSED
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_pressed(pressed: bool) -> void:
	plate_pressed = pressed
	sprite_2d.texture = TEXTURE_PRESSED if plate_pressed else TEXTURE_UNPRESSED

func _on_body_entered(body: Node2D) -> void:
	_update_state(true)

func _on_body_exited(body: Node2D) -> void:
	if area_2d.get_overlapping_bodies().size() == 0:
		_update_state(false)
	
func _update_state(bl: bool) -> void:
	_update_pressed(bl)
	
	if connected_obj:
		connected_obj.update_active(bl)
