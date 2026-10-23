extends CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure it processes even when the game is paused

func enable_spotlight_mouse() -> void:
	%FlashlightCursor.toggle_spotlight_mode(true)
