extends Area2D

@onready var parent = get_parent()
@onready var audio = $AudioStreamPlayer2D

func _ready():
	parent.get_node("EnteringBody").freeze_body()

func unfreeze_parent():
	if(parent.freeze): 
		audio.play()
	parent.get_node("EnteringBody").unfreeze_body()

func _on_body_entered(_body):
	call_deferred("unfreeze_parent")
