extends Camera2D

# Zoom
@export var zoom_step := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 1.5

const MAX_LIMIT_APPLY_ATTEMPTS := 10
const CAMERA_DEBUG_LOGS := false
var _limit_apply_attempts := 0

func _ready() -> void:
	visible = true
	position_smoothing_speed = 30
	limit_enabled = true
	call_deferred("_apply_tilemap_limits")
	if CAMERA_DEBUG_LOGS:
		print("Camera ready, applied tilemap limits.")
	process_mode = Node.PROCESS_MODE_ALWAYS

func _apply_tilemap_limits() -> void:
	var tile_maps := _find_tile_map_layers()
	if tile_maps.is_empty():
		_retry_apply_limits()
		return

	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	var has_valid_bounds := false

	for tile_map in tile_maps:
		if tile_map.tile_set == null:
			continue

		var bounds := tile_map.get_used_rect()
		if bounds.size == Vector2i.ZERO:
			continue

		has_valid_bounds = true
		var tile_size := Vector2(tile_map.tile_set.tile_size)
		var tile_half := tile_size * 0.5

		var pos := bounds.position
		var size := bounds.size
		var corners := [
			Vector2(pos),
			Vector2(pos.x + size.x, pos.y),
			Vector2(pos.x + size.x, pos.y + size.y),
			Vector2(pos.x, pos.y + size.y),
		]

		for corner in corners:
			var local_pos := tile_map.map_to_local(corner) - tile_half
			var global_pos := tile_map.to_global(local_pos)
			min_x = min(min_x, global_pos.x)
			max_x = max(max_x, global_pos.x)
			min_y = min(min_y, global_pos.y)
			max_y = max(max_y, global_pos.y)

	if not has_valid_bounds:
		_retry_apply_limits()
		return

	limit_left = int(floor(min_x))
	limit_right = int(ceil(max_x))
	limit_top = int(floor(min_y))
	limit_bottom = int(ceil(max_y))

	if CAMERA_DEBUG_LOGS:
		print("Camera limits set to: left=%d, right=%d, top=%d, bottom=%d" % [limit_left, limit_right, limit_top, limit_bottom])
	
	_limit_min_zoom()

func _retry_apply_limits() -> void:
	_limit_apply_attempts += 1
	if _limit_apply_attempts <= MAX_LIMIT_APPLY_ATTEMPTS:
		call_deferred("_apply_tilemap_limits")

func _find_tile_map_layers() -> Array[TileMapLayer]:
	var scene := SceneManager.current_main_scene if SceneManager != null else null
	if scene == null:
		scene = get_tree().current_scene
	if scene == null:
		return []

	var tile_maps: Array[TileMapLayer] = []
	var stack := [scene]
	while stack.size() > 0:
		var node = stack.pop_back()
		if node is TileMapLayer:
			tile_maps.append(node as TileMapLayer)
		for child in node.get_children():
			if child is Node:
				stack.append(child)
	return tile_maps

## Limit the furthest out the camera can zoom based on the size of the tilemap, so that the camera view can never show areas outside the tilemap limits.
func _limit_min_zoom() -> void:
	var width_zoom_limit:float = get_viewport_rect().size.x/ (limit_right - limit_left)
	var height_zoom_limit:float = get_viewport_rect().size.y/ (limit_bottom - limit_top)
	var calculated_min_zoom :float = snapped( max(width_zoom_limit, height_zoom_limit) , zoom_step)
	min_zoom = max(min_zoom, calculated_min_zoom)

func _physics_process(_delta: float) -> void:
		# Handle zoom
	if Input.is_action_just_pressed("zoom_in") and !Input.is_action_pressed("hose"):
		zoom += Vector2(zoom_step, zoom_step)
		zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	elif Input.is_action_just_pressed("zoom_out") and !Input.is_action_pressed("hose"):
		zoom -= Vector2(zoom_step, zoom_step)
		zoom = zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
