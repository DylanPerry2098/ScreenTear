extends ScreenTransition

const FADE_DURATION := 1.0
const TEXT_HOLD_DURATION := 1.0

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $ColorRect/Label

var _tween: Tween

func _ready():
	super._ready()
	color_rect.color.a = 0.0
	color_rect.visible = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = "you died"
	label.visible = true

func fade_in():
	_play_tween(1.0, "fade_in_finished", true)

func fade_out():
	_play_tween(0.0, "fade_out_finished", false)

func _play_tween(target_alpha: float, finished_signal: String, hold_after: bool):
	if _tween:
		_tween.kill()
	color_rect.visible = true
	label.visible = true
	_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(color_rect, "color:a", target_alpha, FADE_DURATION)
	if hold_after and target_alpha >= 1.0:
		_tween.tween_interval(TEXT_HOLD_DURATION)
	_tween.finished.connect(func():
		if target_alpha <= 0.0:
			color_rect.visible = false
			label.visible = false
		emit_signal(finished_signal)
	)
