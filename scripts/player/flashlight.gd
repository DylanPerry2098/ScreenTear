extends Node2D

@export var flashlight_length := 600.0
@export var flashlight_angle_degrees := 45.0

const LINE_RAYCAST_AREA_SCENE := preload("res://scenes/gizmos/line_raycast_area.tscn")

@onready var tilemap: TileManager = _get_tilemap_in_tree()
@onready var point_light :PointLightSource = $PointLight2D

var _line_areas: Array[LineRaycastArea] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !tilemap:
		push_error("No Attached TileMapLayer On " + self.name)
		
	createCone(flashlight_angle_degrees)

func _physics_process(_delta: float) -> void:
	if tilemap:
		tilemap.update_lightblocks(_line_areas, self)

## Create a cone of line raycast areas.
func createCone(degreeCone:float):
	var halfDegreeCone = round(float(degreeCone)/2)
	for deg in range(-halfDegreeCone,halfDegreeCone+1,5):
		var line_area := LINE_RAYCAST_AREA_SCENE.instantiate() as LineRaycastArea
		line_area.set_length(flashlight_length)
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

func turn_off() -> void:
	point_light.turn_off()

func turn_on() -> void:
	point_light.turn_on()
