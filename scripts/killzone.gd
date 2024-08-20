extends Area2D

@onready var restart_timer = $Timer

func _on_body_entered(body):
	if body.name != "Player":
		return
	var entering_body = body.get_node("EnteringBody")
	if entering_body.can_enter and entering_body.can_exit:
		body.die()
	print_debug(self, " killed the player", body)
	restart_timer.start()
	

func _on_timer_timeout():
	print("restart level")
	LevelManager.restart()
