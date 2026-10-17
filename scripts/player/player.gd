class_name Player extends CharacterBody2D

@export var speed := 500.0
@export var jump_strength := 1000.0
@export var gravity := 2000.0

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var light_center: Node2D = $LightCenter

@export var light_distance:float = 10.0

@export var state_machine: StateMachine
@export var state_idle: State
@export var state_run: State
@export var state_jump: State
@export var state_fall: State
@export var state_land: State

var frames_off_floor := 0

func can_jump() -> bool:
	return is_on_floor() or not coyote_timer.is_stopped()

func is_falling() -> bool:
	return frames_off_floor > 1

func flip_sprite_by_velocity() -> void:
	if velocity.x != 0:
		%Sprite2D.flip_h = velocity.x > 0

func _ready() -> void:
	if SceneManager.last_main_scene_resource_uid:
		_find_spawn_position()

	state_machine.init(self, null) #$AnimationPlayer)

func _find_spawn_position() -> void:
	for node in SceneManager.current_main_scene.get_children():
		if node is RoomTransitionArea2D:
			if ResourceLoader.get_resource_uid(node.target_scene) == SceneManager.last_main_scene_resource_uid:
				print("found spawn location from ",)
				global_position = node.get_exit_global_pos(%CollisionShape2D.shape.radius)
				# if node is RoomTransitionArea2D and node.direction == node.Direction.LEFT:
				# 	%Sprite2D.flip_h = true
				return

func _physics_process(delta: float) -> void:
	if is_on_floor():
		frames_off_floor = 0
	elif frames_off_floor == 0:
		frames_off_floor = 1
	else:
		frames_off_floor += 1

	if is_on_ceiling() and velocity.y < 0:
		velocity.y = 0

	if not is_on_floor():
		velocity.y += gravity * delta
	elif state_machine.state != state_jump:
		velocity.y = 0

	state_machine.physics_update(delta)
	move_and_slide()

func _process(delta: float) -> void:
	state_machine.update(delta)
	light_center.look_at(get_global_mouse_position())
