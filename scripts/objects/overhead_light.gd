class_name OverheadLight extends ToggleableObject
	
@onready var point_light = $PointLight2D

@export var light_length := 60.0
@export var light_angle_degrees := 90.0
const LINE_RAYCAST_AREA_SCENE := preload("res://scenes/gizmos/line_raycast_area.tscn")

@export var always_on := false

@onready var tilemap: TileManager = _get_tilemap_in_tree()

var _line_areas: Array[LineRaycastArea] = []
	
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
	if always_on:
		update_active(true)
	
func _physics_process(_delta: float) -> void:
	if tilemap:
		var areas: Array[LineRaycastArea] = _line_areas if active else ([] as Array[LineRaycastArea])
		tilemap.update_lightblocks(areas, self)
	
func update_active(bl: bool) -> void:
	super(bl)
	
	if (bl):
		point_light.show()
	else:
		point_light.hide()

## Create a cone of line raycast areas.
func createCone(degreeCone:float):
	var halfDegreeCone = round(float(degreeCone)/2)
	var offset = 90;
	for deg in range(-halfDegreeCone,halfDegreeCone+1,10):
		deg += offset
		var line_area := LINE_RAYCAST_AREA_SCENE.instantiate() as LineRaycastArea
		line_area.set_length(light_length)
		line_area.rotation_degrees = deg
		add_child(line_area)
		_line_areas.append(line_area)

func _get_tilemap_in_tree():
	for node in get_tree().root.get_children():
		if node is TileManager:
			return node
		for node2 in node.get_children():
			if node2 is TileManager:
				return node2
	return
