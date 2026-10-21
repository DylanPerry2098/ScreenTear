class_name EnemyPathfinding extends NavigationAgent2D
## Used by enemies to navigate relative to the player while avoiding obstacles. [br]
## Only called by states, does nothing on its own. [br]
## Ensure that the enemy is set to the correct navigation layer based on its size.


@export var enemy_body: BaseEnemy = null ## The enemy's body, used to access its movement type and speed.
@export var collision_shape: CollisionShape2D ## A reference to the enemy's collision shape, used to make space queries and determine what is a valid jump. Will attempt to find automatically under the enemy body if value is not specified.
var _collision_shape_radius: float ## The radius of the enemy's collision shape, stored and used for jump validation. Not to be confused with [radius], which is used by the [NavigationAgent2D] for avoidance.



var target: CharacterBody2D = null ## The character that the enemy is trying to path to (will always be the player, but left flexible in case we want more complex navigation in the future).
var last_target_position := Vector2.ZERO ## The last global position the target was seen at. Tracked and used for safety in case the target ever becomes null unexpectedly. 
var next_path_position := Vector2.ZERO ## The next position in the navigation path.

var intended_velocity := Vector2.ZERO ## The velocity that the agent wants to move at.
var safe_velocity := Vector2.ZERO ## The safe computed velocity after avoidance has been considered.

var wander_position := Vector2.ZERO ## UNUSED. May be used in the future for patrolling enemies.


var last_h_dir := 0

var speed:float ## The cached speed of the enemy at runtime for movement calculations.

func _ready() -> void:
	avoidance_enabled = true
	
	# Try to get avoidance radius from EnemyBody collision shape.
	if collision_shape == null:
		collision_shape = enemy_body.get_node_or_null("CollisionShape2D")
	
	# Try to get the radius from EnemyBody collision shape.
	if collision_shape != null:
		var shape:Shape2D = collision_shape.shape
		if shape is CircleShape2D:
			var circle_shape := shape as CircleShape2D
			radius = circle_shape.radius
		elif shape is CapsuleShape2D:
			var capsule_shape := shape as CapsuleShape2D
			radius = capsule_shape.height / 2.0
		elif shape is RectangleShape2D:
			var rectangle_shape := shape as RectangleShape2D
			radius = rectangle_shape.size.length()
		else:
			radius = 64.0
	else:
		radius = 64.0 ## Default value
	_collision_shape_radius = radius
	
	radius += 2.0 ## Small padding for avoidance.

		
	speed = enemy_body.speed
	max_speed = speed

	velocity_computed.connect(_on_velocity_computed)


func _on_player_lost() -> void:
	target = null
	stop_navigation()

## Set a destination towards the target
func navigate_to_target() -> void:
	navigate_to_point(target.global_position)

## Get the target's global position, or the last known position if the target is currently null. [br]
## This avoids errors from trying to access the target's position when it is null, while still allowing enemies to navigate towards the last known position of the target when they lose sight of it. [br]
func get_target_global_pos() -> Vector2:
	if target != null:
		last_target_position = target.global_position
		return target.global_position
	else:
		return last_target_position

func stop_navigation() -> void:
	set_target_position(enemy_body.global_position)
	intended_velocity = Vector2.ZERO
	velocity = intended_velocity
	safe_velocity = Vector2.ZERO
	enemy_body.velocity = Vector2.ZERO # Stop pathfinding movement -- this will preserve external forces

func _on_velocity_computed(computed_velocity: Vector2) -> void:
	var new_h_dir:int = signi(int(computed_velocity.x))
	if new_h_dir != 0:
		last_h_dir = new_h_dir
	safe_velocity = computed_velocity

## Set a destination with NavAgent and move towards it.
func navigate_to_point(point:Vector2) -> void:
	target_position = point
	next_path_position = get_next_path_position()
	_movement_flying()

## Flying enemies move straight towards the next path position.
func _movement_flying() -> void:
	intended_velocity = enemy_body.global_position.direction_to(next_path_position) * speed
	velocity = intended_velocity
