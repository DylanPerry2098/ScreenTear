extends StaticBody2D

var plate_pressed := false

@onready var sprite_2d = $Sprite2D

const TEXTURE_UNPRESSED = preload("res://assets/plate_unpressed.png")
const TEXTURE_PRESSED = preload("res://assets/plate_pressed.png")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_pressed(pressed: bool) -> void:
	plate_pressed = pressed
	sprite_2d.texture = TEXTURE_PRESSED if plate_pressed else TEXTURE_UNPRESSED


func _on_body_entered(body: Node2D) -> void:
	_update_pressed(true)
	print("PRESSED")


func _on_body_exited(body: Node2D) -> void:
	_update_pressed(false)
