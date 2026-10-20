class_name LightSources
extends RefCounted

var sources: Array[Node2D] = []

func _init(source: Node2D) -> void:
	if source:
		add_source(source)

func add_source(source: Node2D) -> void:
	if not sources.has(source):
		sources.append(source)

func remove_source(source: Node2D) -> void:
	if sources.has(source):
		sources.erase(source)
		
func is_empty() -> bool:
	return sources.is_empty()
