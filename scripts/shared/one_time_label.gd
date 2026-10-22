class_name OneTimeLabel extends Label
## A Label that floats upwards and fades out over time before freeing itself. [br]
## Useful for damage numbers or other floating UI effects that disappear over time.

## How long (in seconds) for the label to float and fade out
var _duration := 1.0
## How far upwards to float (in pixels)
var _float_distance := 50.0

func _init(display_text: String, pos: Vector2, duration: float = 1.0, float_distance: float = 50.0) -> void:
	add_theme_font_size_override("font_sizes/font_size", 64)
	z_index = 100 # Ensure it appears above most other things
	text = display_text
	modulate = Color(1, 0.5, 0.5) # Light red color for damage numbers
	global_position = pos
	self._duration = duration
	self._float_distance = float_distance

func _ready() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	
	# Float upwards
	tween.tween_property(self, "global_position:y", global_position.y - _float_distance, _duration)
	
	# Fade out
	tween.tween_property(self, "modulate", Color(1, 0.5, 0.5, 0), _duration)
	
	await tween.finished
	queue_free()
