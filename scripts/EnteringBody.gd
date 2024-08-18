class_name EnteringBody

extends Node2D

var entry_timer: Timer

var can_enter_or_exit: bool = true
var has_camera: bool = false
var body: CollisionObject2D
var parent_scene

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
	entry_timer.paused = true

func unfreeze_body():
	body.freeze = false
	entry_timer.paused = false

func _process(_delta):
	if not has_camera and parent_scene.inside:
		call_deferred("unfreeze_body")
	elif not has_camera and not parent_scene.inside:
		call_deferred("freeze_body")
	else:
		pass

func on_enter_or_exit(scene):
	can_enter_or_exit = false
	if is_inside_tree():
		entry_timer.start()
	else:
		entry_timer.autostart = true
	parent_scene = scene

# SIGNALS

func _on_entry_timer_timeout():
	print("Finished entering or exiting")
	can_enter_or_exit = true

func get_parent_view():
	if not has_camera:
		return null
	return body.get_node("Camera/ParentView")
