extends Node

## See `is_rect_containing_ground()` for the public query used by gameplay code.
var _ground: TileMapLayer

const EMPTY_ATLAS_COORD := Vector2i(-1, -1)

var navigation_region_sizes :Dictionary[int,float] = {
	1: 15.0, # small
	2: 15.0, # medium
	3: 15.0, # large
	4: 15.0, # extra large
}

## Registers tile map layers with the manager.
## For ground: the layer is treated as a filled grid where any empty tile is non-ground.
func connect_tilemap(map: TileMapLayer) -> void:
	_ground = map

func _worldspace_to_tilespace(layer: TileMapLayer, worldspace: Vector2) -> Vector2i:
	if not layer:
		return Vector2i.ZERO
	var local := layer.to_local(worldspace)
	return layer.local_to_map(local)

func _tilespace_to_worldspace(layer: TileMapLayer, tilespace: Vector2i) -> Vector2:
	if not layer:
		return Vector2.ZERO
	var local := layer.map_to_local(tilespace)
	return layer.to_global(local)

func _is_tile_at(layer: TileMapLayer, pos: Vector2i) -> bool:
	return layer != null and layer.get_cell_atlas_coords(pos) != EMPTY_ATLAS_COORD

func _bounds_from_points(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()

	var min_x := points[0].x
	var max_x := points[0].x
	var min_y := points[0].y
	var max_y := points[0].y
	for point in points:
		min_x = minf(min_x, point.x)
		max_x = maxf(max_x, point.x)
		min_y = minf(min_y, point.y)
		max_y = maxf(max_y, point.y)

	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

## Public ground query for burrowing logic.
## The player and burrowing enemies call this to ensure a width x height rectangle
## of solid tiles exists that contains the provided world-space point.
func is_rect_containing_ground(include: Vector2, width: int, height: int) -> bool:
	return _is_rect_containing(_ground, include, width, height)

func get_drop_pos_ground(start: Vector2, max_depth: int) -> Vector2:
	return _get_drop_pos(_ground, start, max_depth)

func _get_drop_pos(layer: TileMapLayer, start_raw: Vector2, max_depth: int) -> Vector2:
	if not layer:
		push_error("Cannot find a drop position without a registered ground tilemap.")
		return Vector2.ZERO

	var start := _worldspace_to_tilespace(layer, start_raw)
	
	for y: int in range(start.y, start.y + max_depth + 1):
		if not _is_tile_at(layer, Vector2i(start.x, y)):
			return _tilespace_to_worldspace(layer, Vector2i(start.x, y))
	
	push_error("No drop position found for the given max depth! You must test exceeds_max_depth first")
	return Vector2.ZERO

func exceeds_max_depth_ground(start: Vector2, max_depth: int) -> bool:
	return _exceeds_max_depth(_ground, start, max_depth)

func _exceeds_max_depth(layer: TileMapLayer, start_raw: Vector2, max_depth: int) -> bool:
	if not layer:
		return true

	var start := _worldspace_to_tilespace(layer, start_raw)
		
	for y: int in range(start.y, start.y + max_depth + 1):
		if not _is_tile_at(layer, Vector2i(start.x, y)): return true
	
	return false

## Returns true if all sampled points in a radius around center are on the requested
## navigation layer. Sampling step defaults to 8 pixels for performance.
func is_circle_within_navigation_layer(center: Vector2, radius: float, navigation_layer: int, sample_step: float = 8.0) -> bool:
	if radius <= 0.0:
		return false
	var step = max(1.0, sample_step)
	var radius_sq := radius * radius
	var boundary := [
		center + Vector2(radius, 0.0),
		center + Vector2(-radius, 0.0),
		center + Vector2(0.0, radius),
		center + Vector2(0.0, -radius)
	]
	for point in boundary:
		if not _is_point_in_navigation_layer(point, navigation_layer):
			return false

	var x := center.x - radius
	while x <= center.x + radius:
		var y := center.y - radius
		while y <= center.y + radius:
			var offset := Vector2(x - center.x, y - center.y)
			if offset.length_squared() <= radius_sq:
				if not _is_point_in_navigation_layer(Vector2(x, y), navigation_layer):
					return false
			y += step
		x += step

	return true

## Look for a width x height grid of filled tiles inside "layer",
## which contain "include"
func _is_rect_containing(layer: TileMapLayer, include_raw: Vector2, 
		width: int, height: int) -> bool:
	
	if not layer:
		return false
	
	var include := _worldspace_to_tilespace(layer, include_raw)
	
	for x: int in range(include.x - width + 1, include.x + width):
		for y: int in range(include.y - height + 1, include.y + height):
			if _is_rect(layer, x, y, width, height): return true
	
	return false

## Is the specified rectangle fully present inside "layer", i.e. no missing tiles
func _is_rect(layer: TileMapLayer, x0: int, y0: int, w: int, h: int) -> bool:
	
	for x: int in range(x0, x0 + w):
		for y: int in range(y0, y0 + h):
			if not _is_tile_at(layer, Vector2i(x, y)): return false
	
	return true

func _is_point_in_navigation_layer(point: Vector2, navigation_layer: int) -> bool:
	var world := get_viewport().get_world_2d()
	if world == null:
		return false
	var nav_map: RID
	if world.has_method("get_navigation_map"):
		nav_map = world.get_navigation_map()
	else:
		nav_map = world.navigation_map
	if nav_map == RID():
		return false

	var closest_point_owner := NavigationServer2D.map_get_closest_point_owner(nav_map, point)
	if closest_point_owner == RID():
		return false
	var layer_mask := 1 << (navigation_layer - 1)
	var layers := NavigationServer2D.region_get_navigation_layers(closest_point_owner)
	if (layers & layer_mask) == 0:
		return false

	var closest := NavigationServer2D.map_get_closest_point(nav_map, point)
	return closest.distance_to(point) <= 0.5
