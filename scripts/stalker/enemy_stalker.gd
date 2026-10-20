class_name Stalker extends BaseEnemy

@export var chase_state: State

var frozen: bool = false

func set_freeze(b: bool) -> void:
    frozen = b