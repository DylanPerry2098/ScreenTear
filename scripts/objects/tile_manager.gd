class_name TileManager extends TileMapLayer

var _lit_up_tiles: Dictionary[Vector2i, LightSources]

var _frozen_stalkers: Array[Stalker] = []
var _stalker_frame_tracker: Dictionary[Stalker, int] = {}

func _player_occupies_tile(tile_coords: Vector2i) -> bool:
	var player := Player.player_instance
	if not player:
		return false

	var collision_shape := player.get_node("%CollisionShape2D") as CollisionShape2D
	if not collision_shape or not collision_shape.shape:
		return false

	var shape_bounds := collision_shape.shape.get_rect()
	var shape_corners := [
		shape_bounds.position,
		shape_bounds.position + Vector2(shape_bounds.size.x, 0),
		shape_bounds.position + Vector2(0, shape_bounds.size.y),
		shape_bounds.end
	]
	var player_bounds := Rect2(collision_shape.global_transform * shape_corners[0], Vector2.ZERO)
	for index in range(1, shape_corners.size()):
		player_bounds = player_bounds.expand(collision_shape.global_transform * shape_corners[index])

	var tile_center := map_to_local(tile_coords)
	var tile_size := Vector2(tile_set.tile_size)
	var tile_bounds := Rect2(tile_center - tile_size / 2.0, tile_size)
	var tile_corners := [
		tile_bounds.position + Vector2(tile_bounds.size.x, 0),
		tile_bounds.position + Vector2(0, tile_bounds.size.y),
		tile_bounds.end
	]
	var tile_world_bounds := Rect2(global_transform * tile_bounds.position, Vector2.ZERO)
	for corner in tile_corners:
		var world_corner = global_transform * corner
		tile_world_bounds = tile_world_bounds.expand(world_corner)

	return player_bounds.intersects(tile_world_bounds, true)

func _get_colliding_rays(rays: Array[RayCast2D]) -> Array[RayCast2D]:
	var colliding_rays: Array[RayCast2D] = []
	for ray in rays:
		if ray.is_colliding():
			colliding_rays.append(ray)
	return colliding_rays

func update_lightblocks(rays: Array[RayCast2D], sender: Node2D):

	var hit_tiles: Array[Vector2i]
	var hit_stalkers: Array[Stalker]
	var current_frame := Engine.get_physics_frames()

	for ray in rays:
		if not ray.is_colliding():
			continue
		elif ray.get_collider() == self: 
			var tilemap := self
			var collision_point := ray.get_collision_point() - ray.get_collision_normal() * 0.5
			var tile_coords := local_to_map(to_local(collision_point))
			if _player_occupies_tile(tile_coords):
				continue
			var source_id := tilemap.get_cell_source_id(tile_coords)
			if source_id in [0,2,3,4]:
				hit_tiles.append(tile_coords)
				if _tile_already_lit(tile_coords):
					_lit_up_tiles[tile_coords].add_source(sender)
				else:
					_lit_up_tiles[tile_coords] = LightSources.new(sender)
		elif ray.get_collider() is Stalker:
			var stalker := ray.get_collider() as Stalker
			hit_stalkers.append(stalker)
			if stalker not in _frozen_stalkers:
				_frozen_stalkers.append(stalker)
			_stalker_frame_tracker[stalker] = current_frame
		else:
			continue

	for tile_coords in hit_tiles: # Tile may or may not need to be lit
		_update_light_tile_sprite(tile_coords, true)
	
	for tile_coords in _lit_up_tiles:
		if tile_coords not in hit_tiles:
			var sources = _lit_up_tiles[tile_coords]
			sources.remove_source(sender)
			if sources.is_empty(): # Tile needs to be unlit
				_update_light_tile_sprite(tile_coords, false)
	
	for stalker in _frozen_stalkers:
		if stalker not in hit_stalkers and _stalker_frame_tracker.get(stalker, -1) < current_frame:
			stalker.set_freeze(false)
		else:
			stalker.set_freeze(true)

func _update_light_tile_sprite(tile_coords: Vector2i, lit: bool) -> void:
	var source_id := self.get_cell_source_id(tile_coords)
	if lit:
		match source_id:
			2: set_cell(tile_coords, 0, Vector2i.ZERO) # dark -> light
			3: set_cell(tile_coords, 4, Vector2i.ZERO) # unseen -> seen
			_: pass
	else:
		match source_id:
			0: set_cell(tile_coords, 2, Vector2i.ZERO) # light -> dark
			4: erase_cell(tile_coords)                 # seen -> empty
			_: pass

func _tile_already_lit(tile_coords: Vector2i) -> bool:
	return _lit_up_tiles.has(tile_coords)

@export var margin := 1 ## Extra tiles to pad the navigation region beyond used cells.
@export var auto_generate_on_ready := true ## If true, generates the navigation mesh in _ready().

const NAVIGATION_PHYSICS_LAYERS := [0, 2] # Collision layers 1 and 7.

var nav_regions: Dictionary[int,NavigationRegion2D] = {}
var ground_region: NavigationRegion2D

func _ready() -> void:
	# Register the TileMapLayer with the TileMapManager
	TileMapManager.connect_tilemap(self)

	if auto_generate_on_ready:
		_ensure_nav_regions()
		_ensure_ground_region()
		generate_navigation_mesh()

func _ensure_nav_regions() -> void:
	for region_layer in TileMapManager.navigation_region_sizes:
		var existing_region := NavigationRegion2D.new()
		existing_region.name = ("NavRegion" + str(region_layer) + "px" + str(TileMapManager.navigation_region_sizes[region_layer]))
		add_child(existing_region)
		# Optionally set owner so it appears in the scene tree when saving.
		existing_region.owner = get_owner()

		existing_region.navigation_layers = 1 << (region_layer - 1)

		nav_regions[region_layer] = existing_region

func _ensure_ground_region() -> void:
	if ground_region:
		return
	ground_region = NavigationRegion2D.new()
	ground_region.name = "NavRegionGround"
	add_child(ground_region)
	ground_region.owner = get_owner()
	# Navigation layer 10
	ground_region.navigation_layers = 1 << 9

func generate_navigation_mesh() -> void:
	if nav_regions.is_empty():
		push_warning("No navigation regions found. Ensure that _ensure_nav_regions() is called before generate_navigation_mesh().")
		return
	if not ground_region:
		push_warning("No ground navigation region found. Ensure that _ensure_ground_region() is called before generate_navigation_mesh().")
		return

	# get the bounds of the tilemap in tile coordinates
	var bounds := get_used_rect()
	var tile_size := Vector2(tile_set.tile_size)
	# We need to offset the points by half a tile to get the corners instead of centers
	var tile_half := tile_size * 0.5

	# build outer outline using top-left corners (map_to_local returns cell centers)
	var corners := [
		bounds.position - Vector2i(margin, margin),
		Vector2(bounds.position.x + bounds.size.x + margin, bounds.position.y - margin),
		bounds.position + bounds.size + Vector2i(margin, margin),
		Vector2(bounds.position.x - margin, bounds.position.y + bounds.size.y + margin),
	]

	var points := PackedVector2Array()
	for corner in corners:
		points.append(map_to_local(corner) - tile_half)

	var holes: Array[PackedVector2Array] = []
	# carve holes for any tile collision polygon on the first physics layer (physical collisions)
	for cell in get_used_cells():
		var tile_data := get_cell_tile_data(cell)
		if tile_data == null:
			continue
		var cell_center := map_to_local(cell)
		for physics_layer in NAVIGATION_PHYSICS_LAYERS:
			for polygon_index in tile_data.get_collision_polygons_count(physics_layer):
				var polygon_points := tile_data.get_collision_polygon_points(physics_layer, polygon_index)
				if polygon_points.is_empty():
					continue

				var hole := PackedVector2Array()
				for point in polygon_points:
					hole.append(cell_center + point)

				# Clockwise winding signals a hole to the baker
				hole.reverse()

				holes.append(hole)

	# Now that we have the outer points and holes, we can create a navigation mesh for each agent size.
	for region_layer in TileMapManager.navigation_region_sizes:
		var region: NavigationRegion2D = nav_regions.get(region_layer)

		var new_navigation_mesh := NavigationPolygon.new()
		new_navigation_mesh.agent_radius = TileMapManager.navigation_region_sizes[region_layer]
		new_navigation_mesh.add_outline(points)

		for hole in holes:
			new_navigation_mesh.add_outline(hole)

		NavigationServer2D.bake_from_source_geometry_data(
			new_navigation_mesh,
			NavigationMeshSourceGeometryData2D.new()
		)

		region.navigation_polygon = new_navigation_mesh
		region.navigation_layers = 1 << (region_layer - 1)

func _edge_key(a: Vector2, b: Vector2) -> String:
	if a.x < b.x or (a.x == b.x and a.y <= b.y):
		return str(a.x) + "," + str(a.y) + "|" + str(b.x) + "," + str(b.y)
	return str(b.x) + "," + str(b.y) + "|" + str(a.x) + "," + str(a.y)

func _collect_boundary_edges(polygons: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	# Count edge usage; edges only used once are part of the outer boundary.
	var edge_counts: Dictionary[String, int] = {}
	var edge_points: Dictionary[String, PackedVector2Array] = {}
	for polygon in polygons:
		var count := polygon.size()
		if count < 2:
			continue
		for i in range(count):
			var a := polygon[i]
			var b := polygon[(i + 1) % count]
			var key := _edge_key(a, b)
			edge_counts[key] = edge_counts.get(key, 0) + 1
			if not edge_points.has(key):
				edge_points[key] = PackedVector2Array([a, b])

	var boundary_edges: Array[PackedVector2Array] = []
	for key in edge_counts:
		if edge_counts[key] == 1:
			boundary_edges.append(edge_points[key])
	return boundary_edges

func _build_outlines_from_edges(edges: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	# Build adjacency then walk edges into closed loops.
	var adjacency = {}
	for edge in edges:
		var a := edge[0]
		var b := edge[1]
		if not adjacency.has(a):
			adjacency[a] = []
		if not adjacency.has(b):
			adjacency[b] = []
		adjacency[a].append(b)
		adjacency[b].append(a)

	var outlines: Array[PackedVector2Array] = []
	var used_edges: Dictionary[String, bool] = {}
	for edge in edges:
		var start := edge[0]
		var next := edge[1]
		var start_key := _edge_key(start, next)
		if used_edges.has(start_key):
			continue

		var outline := PackedVector2Array()
		outline.append(start)
		var prev := start
		var current := next
		used_edges[start_key] = true

		while current != start:
			outline.append(current)
			var neighbors = adjacency[current]
			if neighbors.is_empty():
				break
			var candidate = neighbors[0]
			if neighbors.size() > 1 and candidate == prev:
				candidate = neighbors[1]
			var edge_key := _edge_key(current, candidate)
			if used_edges.has(edge_key):
				break
			used_edges[edge_key] = true
			prev = current
			current = candidate

		outlines.append(outline)

	return outlines


func _polygon_bounds(points: PackedVector2Array) -> Rect2:
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
