class_name Door extends ToggleableObject

@onready var collider = $CollisionShape2D
@onready var occluder = $LightOccluder2D
	
func _init() -> void:
	super(
		preload("res://assets/door_open.png"),
		preload("res://assets/door_close.png")
	)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func update_active(bl: bool) -> void:
	super.update_active(bl)
	
	collider.set_deferred("disabled", bl)
	occluder.visible = !bl
