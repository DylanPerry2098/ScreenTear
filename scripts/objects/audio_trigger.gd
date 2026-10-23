class_name AudioTrigger extends Area2D
## Switches the global gameplay music when the player enters this area.

@export_range(0, 2) var track_index: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		GlobalAudioManager.play_track(track_index)
