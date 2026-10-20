@abstract
class_name ToggleableObject extends Node2D

var active := false

@onready var sprite_2d = $Sprite2D

var TEXTURE_OFF: Resource
var TEXTURE_ON: Resource

func _init(active_texture: Resource, inactive_texture: Resource) -> void:
	TEXTURE_OFF = inactive_texture
	TEXTURE_ON = active_texture

func _ready() -> void:
	update_active(false)

func update_active(bl: bool) -> void:
	active = bl
	sprite_2d.texture = TEXTURE_ON if active else TEXTURE_OFF
