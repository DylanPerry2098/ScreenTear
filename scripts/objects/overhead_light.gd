class_name OverheadLight extends ToggleableObject
	
@onready var point_light = $PointLight2D
	
func _init() -> void:
	super(
		preload("res://assets/overhead_light_on.png"),
		preload("res://assets/overhead_light_off.png")
	)
	
func update_active(bl: bool) -> void:
	super(bl)
	
	if (bl):
		point_light.show()
	else:
		point_light.hide()
