class_name PointLightSource extends PointLight2D

@onready var _max_energy: float = energy

@onready var _max_scale: Vector2 = scale

func _ready() -> void:
	energy = 0.0
	LightManager.register_light_source(self)

func _exit_tree() -> void:
	LightManager.unregister_light_source(self)

func turn_on() -> void:
	var energy_tween = create_tween()
	var width_tween = create_tween()

	energy = 0.0
	scale = Vector2(_max_scale.x, 0)

	energy_tween.tween_property(self, "energy", _max_energy, 0.25)
	width_tween.tween_property(self, "scale", _max_scale, 0.25)

func turn_off() -> void:
	var energy_tween = create_tween()
	var width_tween = create_tween()

	energy_tween.tween_property(self, "energy", 0.0, 0.25)
	width_tween.tween_property(self, "scale", Vector2(_max_scale.x, 0), 0.25)
