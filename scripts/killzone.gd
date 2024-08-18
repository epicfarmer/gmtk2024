extends Area2D

@onready var restart_timer = $Timer

func _on_body_entered(body):
	if body.name != "Player":
		return
	body.die()
	restart_timer.start()
	

func _on_timer_timeout():
	print("restart level")
	LevelManager.restart()
