extends ScreenTransition

const FADE_DURATION := 0.25

@onready var color_rect: ColorRect = $ColorRect

var _tween: Tween

func _ready():
	super._ready()
	color_rect.color.a = 0.0
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_in():
	_play_tween(1.0, "fade_in_finished")

func fade_out():
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
		emit_signal(finished_signal)
	)
