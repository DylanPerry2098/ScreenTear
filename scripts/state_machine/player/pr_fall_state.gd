extends State

func enter(data: Dictionary) -> void:
	#animation_player.play("player/fall_loop")
	if data.get("coyote_time", false):
		parent.coyote_timer.start()

func physics_update(_delta: float) -> Transition:
	parent.flip_sprite_by_velocity()
	parent.velocity.x = input_handler.get_horizontal_movement() * parent.speed

	if parent.is_on_floor():
		return Transition.new(parent.state_land)

	if input_handler.wants_to_jump() and parent.can_jump():
		return Transition.new(parent.state_jump)

	return Transition.NONE
