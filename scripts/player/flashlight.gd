extends Node2D

@export var flashlight_length := 600.0
@export var flashlight_angle_degrees := 45.0

@onready var tilemap: TileManager = get_tree().get_first_node_in_group("light_tilemap")

var _raycasts: Array[RayCast2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !tilemap:
		print("No Attached TileMapLayer On " + self.name)
		
	createCone(flashlight_angle_degrees)

func _physics_process(_delta: float) -> void:
	if tilemap:
		tilemap.update_lightblocks(_raycasts, self)

## Create a cone of raycasts.
func createCone(degreeCone:float):
	var _newCast:RayCast2D
	var halfDegreeCone = round(float(degreeCone)/2)
	for deg in range(-halfDegreeCone,halfDegreeCone+1,5):
		_newCast = RayCast2D.new()
		_newCast.set_collision_mask_value(Layers.PhysicsLayer.LIGHT_BLOCK, true)
		# _newCast.hit_from_inside = true
		_newCast.target_position = Vector2(flashlight_length,0)
		_newCast.rotation_degrees = deg
		add_child(_newCast)
		_raycasts.append(_newCast)
