extends State

var touched_the_floor := false

func enter(_data: Dictionary) -> void:
	animation_player.play("idle")
	touched_the_floor = false

func physics_update(_delta: float) -> Transition:
	parent.flip_sprite_by_velocity()
	if parent.is_on_floor():
		touched_the_floor = true

	if input_handler.get_horizontal_movement() != 0:
		return Transition.new(parent.state_run)

	if input_handler.wants_to_jump() and parent.can_jump():
		return Transition.new(parent.state_jump)

	if parent.is_falling():
		return Transition.new(parent.state_fall, {"coyote_time": touched_the_floor})

	return Transition.NONE
