extends State

var land_animation_finished := false

func enter(_data: Dictionary) -> void:
	parent.velocity.y = 0
	#animation_player.play("player/land")
	land_animation_finished = false
	# await #animation_player.animation_finished
	if _is_active_state():
		#animation_player.play("player/idle")
		land_animation_finished = true

func exit() -> void:
	land_animation_finished = false

func physics_update(_delta: float) -> Transition:
	parent.flip_sprite_by_velocity()
	parent.velocity.x = input_handler.get_horizontal_movement() * parent.speed

	if input_handler.wants_to_jump() and parent.can_jump():
		return Transition.new(parent.state_jump)

	if not land_animation_finished:
		return Transition.NONE

	if input_handler.get_horizontal_movement() != 0:
		return Transition.new(parent.state_run)

	return Transition.new(parent.state_idle)
