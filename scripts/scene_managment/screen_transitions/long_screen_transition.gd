extends ScreenTransition

const DELAY_DURATION := 1.0
const FADE_DURATION := 0.5
const DELAY_OUT_DURATION := 8.0

@onready var color_rect: ColorRect = $ColorRect

var _tween: Tween

func _ready():
	super._ready()
	color_rect.color.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_in():
	await get_tree().create_timer(DELAY_DURATION).timeout
	_play_tween(1.0, "fade_in_finished")

func fade_out():
	
	GlobalUI.get_child(0).toggle_spotlight_mode(false)
	_play_tween(0.0, "fade_out_finished")

func _play_tween(target_alpha: float, finished_signal: String):
	if _tween:
		_tween.kill()
	color_rect.visible = true
	_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(color_rect, "color:a", target_alpha, FADE_DURATION)
	_tween.finished.connect(func():
		if target_alpha <= 0.0:
			color_rect.visible = false
		await get_tree().create_timer(DELAY_OUT_DURATION).timeout
		emit_signal(finished_signal)
	)
