extends State
@export var jumpsfx: AudioStreamPlayer
var frames_in_state := 0

func enter(_data: Dictionary) -> void:
	jumpsfx.play()
	frames_in_state = 0
	animation_player.play("jump_loop")
	parent.velocity.y = -parent.jump_strength
	parent.coyote_timer.stop()

func exit() -> void:
	frames_in_state = 0

func physics_update(_delta: float) -> Transition:
	parent.flip_sprite_by_velocity()
	parent.velocity.x = input_handler.get_horizontal_movement() * parent.speed

	if Input.is_action_just_released("jump") and parent.velocity.y < 0:
		parent.velocity.y /= 2

	if parent.velocity.y > 0 and frames_in_state > 10:
		return Transition.new(parent.state_fall)

	if frames_in_state > 5 and parent.is_on_floor():
		return Transition.new(parent.state_land)

	frames_in_state += 1
	return Transition.NONE
