class_name EnteringBody

extends Node2D

var entry_timer: Timer

var can_enter: bool = true
var can_exit: bool = true
var has_camera: bool = false
var body: CollisionObject2D
var parent_scene
var frozen: bool = false
var paused: bool = false

func _ready() -> void:
	body = get_parent()
	entry_timer = Timer.new()
	add_child(entry_timer)
	entry_timer.timeout.connect(_on_entry_timer_timeout)
	entry_timer.wait_time = .1
	entry_timer.one_shot = true
	has_camera = body.has_node("Camera")
	parent_scene = body.get_parent()

func freeze_body():
	body.freeze = true
	frozen = true

func unfreeze_body():
	body.freeze = false
	frozen = false

func pause_body():
	# For pausing caused by entry and exit of scene
	if not paused:
		body.freeze = true
		entry_timer.paused = true
	paused = true

func unpause_body():
	# For pausing caused by entry and exit of scene
	if paused and not frozen:
		body.freeze = false
	if paused:
		entry_timer.paused = false
		entry_timer.start()
	paused = false

func _process(_delta):
	if frozen:
		body.freeze = true
	if not has_camera and parent_scene.inside:
		call_deferred("unpause_body")
	elif not has_camera and not parent_scene.inside:
		call_deferred("pause_body")
	else:
		pass

func on_enter(scene):
	can_exit = false
	entry_timer.autostart = true
	if is_inside_tree():
		entry_timer.start()
	print("Timer info")
	print(entry_timer.paused)
	print(entry_timer.autostart)
	print(entry_timer.one_shot)
	print(entry_timer.is_stopped())
	print(entry_timer.time_left)
	print("===")
	parent_scene = scene

	var audio = get_node("../ShrinkSound")
	if audio != null and has_camera:
		audio.play()
		

func on_exit(scene):
	can_enter = false
	entry_timer.autostart = true
	if is_inside_tree():
		entry_timer.start()
	parent_scene = scene
	
	var audio = get_node("../GrowSound")
	if audio != null and has_camera and is_inside_tree():
		audio.play()

# SIGNALS

func _on_entry_timer_timeout():
	print("Finished entering or exiting")
	if not has_camera:
		print("HERE")
	can_enter = true
	can_exit = true
	
func get_parent_view():
	if not has_camera:
		return null
	return body.get_node("Camera/Parent View")
