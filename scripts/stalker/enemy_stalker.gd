class_name Stalker extends BaseEnemy

@export var chase_state: State

var frozen: bool = false

func _ready() -> void:
	super()
	%Area2D.body_entered.connect(_on_body_entered)

func set_freeze(b: bool) -> void:
	frozen = b
	%Area2D.monitoring = !b
	animation_player.play("frozen") if frozen else animation_player.play("moving")

	if !b:
		for body in %Area2D.get_overlapping_bodies():
			if body is Player and !body.dying:
				body.death()

func _on_body_entered(body: Node) -> void:
	if body is Player and !body.dying:
		body.death()
