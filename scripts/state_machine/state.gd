class_name State
extends Node
## Base class for character states in the state machine. [br]
## Provides common properties and methods for all states.

var parent: CharacterBody2D
var animation_player: AnimationPlayer
var input_handler: PlayerInput
var state_machine: StateMachine

# Exposes next states in the editor for debugging/visualization purposes, but doesn't affect actual transitions.
# Key: NodePath to state, Value: short description of the transition.
@export var visible_next_states: Dictionary[NodePath, String] = {}

@export var state_animation: String = ""

func enter(_data: Dictionary) -> void:
	pass
	
func exit() -> void:
	pass
	
func physics_update(_delta: float) -> Transition:
	return Transition.NONE

func update(_delta: float) -> Transition:
	return Transition.NONE

func on_animation_complete() -> Transition:
	return Transition.NONE

func _is_active_state() -> bool:
	return state_machine.state == self