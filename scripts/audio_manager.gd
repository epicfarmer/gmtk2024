extends Node


@onready var music = $AudioStreamPlayer

var stopped = false
var position = null

func stop():
	stopped = true
	position = music.get_playback_position()
	music.stop()

func start():
	if stopped:
		music.play()
		if position != null:
			music.seek(position)
