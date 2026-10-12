extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var x_direction := Input.get_axis("move_left", "move_right")
	var y_direction := Input.get_axis("move_up", "move_down")
	if x_direction or y_direction:
		velocity.x = x_direction * SPEED
		velocity.y = y_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
