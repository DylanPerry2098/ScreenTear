class_name Player extends CharacterBody2D

@export var speed := 500.0
@export var jump_strength := 1000.0
@export var gravity := 2000.0

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var light_center: Node2D = $LightCenter

@export var light_distance:float = 10.0

@export var animation_player: AnimationPlayer

@export var state_machine: StateMachine
@export var state_idle: State
@export var state_run: State
@export var state_jump: State
@export var state_fall: State
@export var state_land: State

@export var flashlighton_sfx: AudioStreamPlayer
@export var flashlightoff_sfx: AudioStreamPlayer

static var player_instance: Player

var dying := false

var frames_off_floor := 0
var _flashlight_turned_off := false

func can_jump() -> bool:
	return is_on_floor() or not coyote_timer.is_stopped()

func is_falling() -> bool:
	return frames_off_floor > 1

func flip_sprite_by_velocity() -> void:
	if velocity.x != 0:
		%Sprite2D.flip_h = velocity.x < 0

func _ready() -> void:
	player_instance = self

	if SceneManager.last_main_scene_resource_uid:
		_find_spawn_position()

	state_machine.init(self, animation_player)

	await get_tree().process_frame
	_flashlight_on()

func _find_spawn_position() -> void:
	for node in SceneManager.current_main_scene.get_children():
		if node is RoomTransitionArea2D:
			if ResourceLoader.get_resource_uid(node.target_scene) == SceneManager.last_main_scene_resource_uid:
				global_position = node.get_exit_global_pos(%CollisionShape2D.shape.radius)
				if node is RoomTransitionArea2D and node.direction == node.Direction.LEFT:
					%Sprite2D.flip_h = true
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

	if !_flashlight_turned_off and state_machine.input_handler.flashlight_pressed():
		flashlight_off()
		
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var crb := c.get_collider() as RigidBody2D
			crb.linear_velocity = -c.get_normal() * 80

func _process(delta: float) -> void:
	state_machine.update(delta)
	light_center.look_at(get_global_mouse_position())

func _flashlight_on():
	_flashlight_turned_off = false
	LightManager.turn_on_all()
	flashlighton_sfx.play()
	
func flashlight_off():
	_flashlight_turned_off = true
	LightManager.turn_off_all()
	flashlightoff_sfx.play()
	
	await get_tree().create_timer(0.5).timeout
	SceneManager.change_scenes(SceneManager.MainScene.SAME)


func death():
	dying = true
	_flashlight_turned_off = true
	LightManager.turn_off_all(%Illumination)
	
	var red_light_tween = create_tween()
	red_light_tween.tween_property(%Illumination, "color", Color(1,0,0,1), 0.25)
	
	await red_light_tween.finished
	
	
	%Illumination.turn_off()
	await get_tree().create_timer(0.75).timeout 
	SceneManager.change_scenes(SceneManager.MainScene.SAME)
