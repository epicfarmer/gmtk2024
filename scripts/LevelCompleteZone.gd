extends Area2D

@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer2D


func _on_body_entered(body):
	if body.name != "Player":
		return
	body.fade_to_black()
	AudioManager.stop()
	audio.play()
	timer.start()



func _on_timer_timeout():
	LevelManager.next_level()
