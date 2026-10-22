extends Node

var _light_sources: Array[PointLightSource] = []

func register_light_source(light_source: PointLightSource) -> void:
	if not _light_sources.has(light_source):
		_light_sources.append(light_source)

func unregister_light_source(light_source: PointLightSource) -> void:
	_light_sources.erase(light_source)

func turn_on_all(exclude: PointLightSource = null) -> void:
	for light_source in _light_sources:
		if is_instance_valid(light_source) and light_source != exclude:
			light_source.turn_on()

func turn_off_all(exclude: PointLightSource = null) -> void:
	for light_source in _light_sources:
		if is_instance_valid(light_source) and light_source != exclude:
			light_source.turn_off()
