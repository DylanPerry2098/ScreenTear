class_name ActivateEnemyArea extends Area2D

@export var enemies_to_freeze: Array[Stalker]

func _ready() -> void:
	for e in enemies_to_freeze:
		e.process_mode = Node.PROCESS_MODE_DISABLED
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		for e in enemies_to_freeze:
			e.process_mode = Node.PROCESS_MODE_INHERIT
