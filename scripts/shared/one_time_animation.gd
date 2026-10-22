class_name OneTimeAnimation extends AnimatedSprite2D
## An AnimatedSprite2D that plays its animation once and then frees itself. [br]
## Useful for death animations or other one-off effects.

## Add an optional fade out time before freeing after the animation finishes. (Also useful as placeholders!)
var _fade_time := 0.0 

func _init(frames: SpriteFrames, pos: Vector2, fade_time: float = 0.0) -> void:
	sprite_frames = frames
	global_position = pos
	self._fade_time = fade_time

func _ready() -> void:
	play()
	animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if _fade_time <= 0.0:
		queue_free()
	else:
		var fadeTween := create_tween()
		fadeTween.tween_property(self,"modulate",Color(1,1,1,0),_fade_time)
		await fadeTween.finished
		queue_free()
