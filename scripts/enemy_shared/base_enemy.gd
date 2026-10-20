class_name BaseEnemy extends CharacterBody2D
## A basic enemy character with a state machine and pathfinding.

@export var speed: float = 50.0

# These variables might be useful later for different movement types.
	## Max horizontal speed when falling or jumping
	# @export var fall_horizontal_speed: float = 500
	## Rate at which to change the current horizontal speed
	## to the desired horizontal speed (when falling)
	# @export var fall_horizontal_correction: float = 1000

	# @export var gravity_up: float = 3000
	# @export var gravity_up: float = 3000

@export var gravity_down: float = 2000

@export var state_machine: StateMachine ## The state machine controlling the enemy's behavior
@export var animation_player: AnimationPlayer ## The animation player for the enemy
@export var pathfinder: EnemyPathfinding ## The pathfinding component for the enemy


@export var sprite: Sprite2D ## The sprite for the enemy, used for flipping and animation

@export var head_position: Node2D
var is_climbing := false
var is_flying := false

func _ready() -> void:

	gravity_down = 0.0
	is_flying = true
	if state_machine:
		state_machine.init(self, animation_player)
	
	# Prevent issues with slopes
	floor_constant_speed = true
	floor_snap_length = 50
	
@export var nodes_to_flip: Array[Node2D]

func _process(delta: float) -> void:
	state_machine.update(delta);

func _physics_process(delta: float) -> void:
	if not state_machine:
		return
	
	state_machine.physics_update(delta);

	move_and_slide()

	if up_direction == Vector2.ZERO:
		up_direction = Vector2.UP
	
## Helper method that faces the enemy a certain direction.
func face_direction(horizontal_dir:float) -> void:
	if horizontal_dir == 0.0 or horizontal_dir == 0:
		return
	for node in nodes_to_flip:
		node.transform.x.x = sign(horizontal_dir) * abs(node.transform.x.x)
	if sprite:
		sprite.flip_h = sign(horizontal_dir) < 0.0
