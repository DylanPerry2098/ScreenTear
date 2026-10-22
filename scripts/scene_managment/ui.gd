class_name UserInterface extends CanvasLayer

static var instance: UserInterface

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS # Ensure it processes even when the game is paused
    instance = self