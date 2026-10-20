class_name BaseChaseState extends State
## Pursue the target using pathfinding.

@export var pathfinder: EnemyPathfinding

func _ready() -> void:
	pathfinder.target = Player.player_instance

func update_internal_velocity() -> void:
	parent.velocity = pathfinder.safe_velocity
			
func exit() -> void:
	pathfinder.stop_navigation()

func physics_update(_delta: float) -> Transition:
	if pathfinder.target and !parent.frozen:
		pathfinder.navigate_to_target()
		update_internal_velocity()
	else:
		pathfinder.stop_navigation()

	return Transition.NONE
