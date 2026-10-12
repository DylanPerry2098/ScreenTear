class_name ScreenTransition extends CanvasLayer
## A screen transition effect, such as fade in/out, used during scene changes.
signal fade_in_finished
signal fade_out_finished

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Ensure it processes even when the game is paused

func fade_in():
    # Visual effect goes here
	emit_signal("fade_in_finished")

func fade_out():
    # Visual effect goes here
	emit_signal("fade_out_finished")
