class_name StateMachine
extends Node
## Manages state transitions for a character using a state machine pattern.

@export var start_state: State
@export var input_handler: PlayerInput

var state: State

func init(parent: CharacterBody2D, animation_player: AnimationPlayer):
	for child in get_children():
		if child is State:
			child.parent = parent
			child.animation_player = animation_player
			child.state_machine = self
			if input_handler:
				child.input_handler = input_handler
	transition(Transition.new(start_state))

func physics_update(delta: float):
	if state:
		var t: Transition = state.physics_update(delta);
		transition(t)

func update(delta: float):
	if state:
		var t: Transition = state.update(delta);
		transition(t)

func transition(t: Transition) -> void:
	if not t: return
	
	if state: state.exit()
	
	state = t.new_state
	state.enter(t.data)

## Optionally called by the end of the current animation
func on_animation_complete() -> void:
	if not state: return
	
	transition(state.on_animation_complete())
	
