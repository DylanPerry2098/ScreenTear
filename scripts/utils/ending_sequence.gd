extends Node2D

const NPC_PLAYER_SCENE := preload("res://scenes/characters/npc_player.tscn")
const META_FLASHLIGHT_OFF_DURATION := 15.0
const DESIRED_NPC_MOUSE_HOVERS := 8

enum EndingSequenceState {
    FALL,
    LAND,
    FLASHLIGHT_OFF,
    FLASHLIGHT_FLICKERING,
    META_FLASHLIGHT_OFF,
    META_FLASHLIGHT_ON,
}

var state = EndingSequenceState.LAND

var seconds_until_flashlight_off = 15.0
var seconds_until_meta_flashlight_on := META_FLASHLIGHT_OFF_DURATION

func _ready():
    # Disable level reset and pausing
    Player.can_reset_level = false
    GlobalAudioManager.stop_track()

func _physics_process(delta: float) -> void:
    match state:
        EndingSequenceState.FALL:
            pass
        EndingSequenceState.LAND:
            seconds_until_flashlight_off -= delta
            if seconds_until_flashlight_off <= 0.0:
                state = EndingSequenceState.FLASHLIGHT_OFF
        EndingSequenceState.FLASHLIGHT_OFF:
            # flashlight flickers off. Lose control of player.
            # Flashlight turns on after player presses F or after 15 seconds have passed
            state = EndingSequenceState.FLASHLIGHT_FLICKERING
            await Player.player_instance.flashlight_flicker_off()
            _replace_player()
            state = EndingSequenceState.META_FLASHLIGHT_OFF
        EndingSequenceState.FLASHLIGHT_FLICKERING:
            pass
        EndingSequenceState.META_FLASHLIGHT_OFF:
            seconds_until_meta_flashlight_on -= delta
            if Input.is_action_just_pressed("turn_off_flashlight") or seconds_until_meta_flashlight_on <= 0.0:
                state = EndingSequenceState.META_FLASHLIGHT_ON
                GlobalUI.enable_spotlight_mouse()
        EndingSequenceState.META_FLASHLIGHT_ON:
            pass

func _replace_player() -> void:
    var player := Player.player_instance
    var camera := player.get_node_or_null("Camera2D") as Camera2D
    var player_position := player.global_position

    if camera:
        camera.reparent(self, true)
        camera.enabled = true

    player.queue_free()

    var npc_player: NPCPlayer = NPC_PLAYER_SCENE.instantiate()
    npc_player.desired_mouse_hovers = DESIRED_NPC_MOUSE_HOVERS
    npc_player.desired_mouse_hovers_reached.connect(_on_desired_npc_mouse_hovers_reached)
    npc_player.global_position = player_position
    add_child(npc_player)

func _on_desired_npc_mouse_hovers_reached() -> void:
    print("Desired NPC mouse hovers reached. Transitioning to credits.")
    SceneManager.change_scenes(
        SceneManager.MainScene.MENU,
        SceneManager.UIScene.NONE,
        SceneManager.ScreenTransitionScene.ENDING
    )