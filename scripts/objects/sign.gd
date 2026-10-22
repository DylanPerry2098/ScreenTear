extends Area2D

@export var text:String = "Hello, World!"

@onready var label:Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	label.visible = false
	label.text = text
	await get_tree().physics_frame
	label.reparent(UserInterface.instance)
	

func _on_body_entered(_body:Node2D):
	label.visible = true

func _on_body_exited(_body:Node2D):
	label.visible = false
