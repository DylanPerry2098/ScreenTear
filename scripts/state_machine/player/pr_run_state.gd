extends State

const IDLE_FRAME_THRESHOLD := 5

var last_x_direction := 0.0
var frames_without_horizontal_input := 0
var turn_animation_playing := false

func enter(_data: Dictionary) -> void:
	#animation_player.play("player/run_start")
	#await animation_player.animation_finished
	# if _is_active_state() and not turn_animation_playing:
	animation_player.play("run_loop") #indent this line after if implemented

func exit() -> void:
	last_x_direction = 0
	frames_without_horizontal_input = 0

func physics_update(_delta: float) -> Transition:
	parent.flip_sprite_by_velocity()
	parent.velocity.x = input_handler.get_horizontal_movement() * parent.speed

	if input_handler.wants_to_jump() and parent.can_jump():
		return Transition.new(parent.state_jump)

	if parent.is_falling():
		return Transition.new(parent.state_fall, {"coyote_time": true})

	if input_handler.get_horizontal_movement() == 0:
		frames_without_horizontal_input += 1
		if frames_without_horizontal_input >= IDLE_FRAME_THRESHOLD:
			return Transition.new(parent.state_idle)
	else:
		frames_without_horizontal_input = 0

	if last_x_direction != 0 and sign(parent.velocity.x) != sign(last_x_direction):
		play_turn_animation()

	last_x_direction = parent.velocity.x if parent.velocity.x != 0 else last_x_direction
	return Transition.NONE

func play_turn_animation() -> void:
	if turn_animation_playing:
		return
	turn_animation_playing = true
	#animation_player.play("player/run_turn")
	#await #animation_player.animation_finished
	turn_animation_playing = false
	#if _is_active_state():
		#animation_player.play("player/run_loop")
