extends Control

@export var credit_screen: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !credit_screen:
		print("No Attached Credit Screen On " + self.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _toggle_credit_screen(bl: bool) -> void:
	if credit_screen:
		credit_screen.visible = bl


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")


func _on_credits_button_pressed() -> void:
	_toggle_credit_screen(true)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_credit_close_button_pressed() -> void:
	_toggle_credit_screen(false)
