extends Area2D

@onready var parent = get_parent()

func _ready():
	parent.freeze = true

func unfreeze_parent():
	parent.freeze = false

func _on_body_entered(_body):
	call_deferred("unfreeze_parent")
