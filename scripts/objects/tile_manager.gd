class_name TileManager extends TileMapLayer

var _lit_up_tiles: Dictionary[Vector2i, LightSources]

func _get_colliding_rays(rays: Array[RayCast2D]) -> Array[RayCast2D]:
	var colliding_rays: Array[RayCast2D] = []
	for ray in rays:
		if ray.is_colliding():
			colliding_rays.append(ray)
	return colliding_rays

func update_lightblocks(rays: Array[RayCast2D], sender: Node2D):

	var hit_tiles: Array[Vector2i]

	for ray in rays:
		if not ray.is_colliding() or ray.get_collider() != self:
			continue

		var tilemap := self
		var collision_point := ray.get_collision_point() - ray.get_collision_normal() * 0.5
		var tile_coords := local_to_map(to_local(collision_point))
		var source_id := tilemap.get_cell_source_id(tile_coords)
		if source_id in [0,2,3,4]:
			hit_tiles.append(tile_coords)
			if _tile_already_lit(tile_coords):
				_lit_up_tiles[tile_coords].add_source(sender)
			else:
				_lit_up_tiles[tile_coords] = LightSources.new(sender)

	for tile_coords in hit_tiles: # Tile may or may not need to be lit
		_update_light_tile_sprite(tile_coords, true)
	
	for tile_coords in _lit_up_tiles:
		if tile_coords not in hit_tiles:
			var sources = _lit_up_tiles[tile_coords]
			sources.remove_source(sender)
			if sources.is_empty(): # Tile needs to be unlit
				_update_light_tile_sprite(tile_coords, false)

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
