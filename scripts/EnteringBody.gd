class_name EnteringBody

extends Node2D

var entry_timer: Timer

var can_enter: bool = true
var can_exit: bool = true
var has_camera: bool = false
var body: CollisionObject2D
var parent_scene
var frozen: bool = false

func _ready() -> void:
	body = get_parent()
	entry_timer = Timer.new()
	add_child(entry_timer)
	entry_timer.timeout.connect(_on_entry_timer_timeout)
	entry_timer.wait_time = .1
	entry_timer.one_shot = true
	has_camera = body.has_node("Camera")
	parent_scene = body.get_parent()
	if has_camera:
		frozen = false
	else:
		frozen = true

func freeze_body():
	if not frozen:
		body.freeze = true
		entry_timer.paused = true

func unfreeze_body(): 
	if frozen:
		body.freeze = false
		entry_timer.paused = false

func _process(_delta):
	if frozen:
		if not body.freeze:
			frozen = false
		else:
			return
	if not has_camera and parent_scene.inside:
		call_deferred("unfreeze_body")
	elif not has_camera and not parent_scene.inside:
		call_deferred("freeze_body")
	else:
		pass

func on_enter(scene):
	can_exit = false
	if is_inside_tree():
		entry_timer.start()
	else:
		entry_timer.autostart = true
	parent_scene = scene

	if not (has_camera or not self.frozen):
		return
		
	var audio = get_node("../ShrinkSound")

	if (audio != null) and is_inside_tree():
		audio.play() 

func on_exit(scene):
	can_enter = false
	if is_inside_tree():
		entry_timer.start()
	else:
		entry_timer.autostart = true
	parent_scene = scene
	
	if not (has_camera or not self.frozen):
		return
	var audio = get_node("../GrowSound")
	if audio != null:
		audio.play() 

# SIGNALS

func _on_entry_timer_timeout():
	print("Finished entering or exiting")
	can_enter = true
	can_exit = true
	

func get_parent_view():
	if not has_camera:
		return null
	return body.get_node("Camera/ParentView")
