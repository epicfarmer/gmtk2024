extends Area2D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer2D


func _on_body_entered(body):
	if body.name != "Player":
		return
	var entering_body = body.get_node("EnteringBody")
	if not entering_body.can_enter:
		return
	if not entering_body.can_exit:
		return
	body.fade_to_black()
	AudioManager.stop()
	audio.play()
	timer.start()
	print_debug(body, "completed", self)



func _on_timer_timeout():
	LevelManager.next_level()

