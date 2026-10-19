class_name OverheadLight extends ToggleableObject
	
@onready var point_light = $PointLight2D

@export var light_length := 60.0
@export var light_angle_degrees := 90.0

@onready var tilemap: TileManager = get_tree().get_first_node_in_group("light_tilemap")

var _raycasts: Array[RayCast2D]
	
func _init() -> void:
	super(
		preload("res://assets/overhead_light_on.png"),
		preload("res://assets/overhead_light_off.png")
	)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if !tilemap:
		print("No Attached TileMapLayer On " + self.name)
		
	createCone(light_angle_degrees)
	
func _physics_process(_delta: float) -> void:
	if tilemap:
		var rays: Array[RayCast2D] = _raycasts if active else ([] as Array[RayCast2D])
		tilemap.update_lightblocks(rays, self)
	
func update_active(bl: bool) -> void:
	super(bl)
	
	if (bl):
		point_light.show()
	else:
		point_light.hide()

## Create a cone of raycasts.
func createCone(degreeCone:float):
	var _newCast:RayCast2D
	var halfDegreeCone = round(float(degreeCone)/2)
	var offset = 90;
	for deg in range(-halfDegreeCone,halfDegreeCone+1,10):
		deg += offset
		_newCast = RayCast2D.new()
		_newCast.set_collision_mask_value(Layers.PhysicsLayer.LIGHT_BLOCK, true)
		# _newCast.hit_from_inside = true
		_newCast.target_position = Vector2(light_length,0)
		_newCast.rotation_degrees = deg
		add_child(_newCast)
		_raycasts.append(_newCast)
