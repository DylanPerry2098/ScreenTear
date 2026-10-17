extends Node2D

@export var flashlight_length := 600.0
@export var flashlight_angle_degrees := 45.0

var _raycasts: Array[RayCast2D]

var _lit_up_tiles: Dictionary[Vector2i, TileMapLayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createCone(flashlight_angle_degrees)


func _physics_process(_delta: float) -> void:
	_update_lightblocks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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

## Find and return the closest Area2D detected by aim assist.
func search() -> Area2D:
	var colliders := _getColliders()
	if colliders.size() == 0:
		return

	var closestEnemy: Area2D = null
	
	for bod in colliders:
		if bod.is_in_group("healthComponent"):
			if closestEnemy == null:
				closestEnemy = bod
			elif global_position.distance_to(bod.global_position) < global_position.distance_to(closestEnemy.global_position):
				closestEnemy = bod
	return closestEnemy

## Return an array of each node colliding with aim assist.
func _getColliders() -> Array[Node2D]:
	var colliders = []
	for child in get_children():
		if child.is_colliding() and !(child in colliders):
			
			colliders.append(child.get_collider())
	return colliders

func _get_colliding_rays() -> Array[RayCast2D]:
	var colliding_rays: Array[RayCast2D] = []
	for ray in _raycasts:
		if ray.is_colliding():
			colliding_rays.append(ray)
	return colliding_rays

func _getCollisionPointss() -> Array[Vector2]:
	var collision_points: Array[Vector2] = []
	for ray in _raycasts:
		if ray.is_colliding():
			collision_points.append(ray.get_collision_point())
	return collision_points


func _update_lightblocks():

	var _new_lit_up_tiles: Dictionary[Vector2i, TileMapLayer]

	var colliding_rays = _get_colliding_rays()

	for cr in colliding_rays:
		var collider := cr.get_collider()

		if collider is TileMapLayer:
			var tilemap := collider as TileMapLayer 
			var collision_point := cr.get_collision_point() + Vector2(1,0).rotated(get_parent().rotation)
			var tile_coords := tilemap.local_to_map(collision_point)
			var source_id := tilemap.get_cell_source_id(tile_coords)
			if source_id in [0,2,3,4]:
				_new_lit_up_tiles[tile_coords] = (collider as TileMapLayer)
			
	

	for tile_coords in _new_lit_up_tiles:
		if tile_coords in _lit_up_tiles: # Tile is already lit up
			continue
		else: # Tile needs to be lit up
			var tilemap := _new_lit_up_tiles[tile_coords]
			var source_id := tilemap.get_cell_source_id(tile_coords)
			match source_id:
				2: tilemap.set_cell(tile_coords, 0, Vector2.ZERO)
				3: tilemap.set_cell(tile_coords, 4, Vector2.ZERO)
				_: pass
	
	for tile_coords in _lit_up_tiles: # Tile needs to be turned off
		if tile_coords not in _new_lit_up_tiles:
			var tilemap := _lit_up_tiles[tile_coords] 
			var source_id := tilemap.get_cell_source_id(tile_coords)
			match source_id:
				0: tilemap.set_cell(tile_coords, 2, Vector2.ZERO)
				4: tilemap.set_cell(tile_coords, -1, Vector2.ZERO)
				_: pass
			
	_lit_up_tiles = _new_lit_up_tiles
