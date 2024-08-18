extends Area2D

@onready var parent = get_parent()
@onready var audio = $AudioStreamPlayer2D

func _ready():
	parent.freeze = true

func unfreeze_parent():
	if(parent.freeze): 
		audio.play()
	parent.freeze = false

func _on_body_entered(_body):
	call_deferred("unfreeze_parent")
