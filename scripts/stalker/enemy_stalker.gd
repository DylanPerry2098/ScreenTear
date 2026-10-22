class_name Stalker extends BaseEnemy

@export var chase_state: State

var frozen: bool = false

func _ready() -> void:
	super()
	%Area2D.body_entered.connect(_on_body_entered)

func set_freeze(b: bool) -> void:
	frozen = b

func _on_body_entered(body: Node) -> void:
	if body is Player and !body.dying:
		body.death()