class_name Transition
extends Object

## The new state to transition to
var new_state: State
## Any extra information to be passed to the new state
var data: Dictionary


const NONE: Transition = null

func _init(n: State, d: Dictionary = {}):
	new_state = n
	data = d
