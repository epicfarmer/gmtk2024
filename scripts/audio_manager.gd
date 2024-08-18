extends Node


@onready var music = $AudioStreamPlayer

var stopped = false

func stop():
	stopped = true
	music.stop()

func start():
	if stopped:
		music.play()
