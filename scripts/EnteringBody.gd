class_name EnteringBody

extends Node2D

var entry_timer: Timer

var can_enter_or_exit: bool = true
var has_camera: bool = false
var body: CollisionObject2D

func _ready() -> void:
	body = get_parent()
	entry_timer = Timer.new()
	add_child(entry_timer)
	entry_timer.timeout.connect(_on_entry_timer_timeout)
	entry_timer.wait_time = 0.1
	entry_timer.one_shot = true
	has_camera = body.has_node("Camera")

func freeze_body():
	body.freeze = true

func unfreeze_body():
	body.freeze = false

func on_enter_or_exit():
	can_enter_or_exit = false
	print(scale)
	entry_timer.start()

# SIGNALS

func _on_entry_timer_timeout():
	print("Finished entering or exiting")
	can_enter_or_exit = true

func get_parent_view():
	if not has_camera:
		return null
	return body.get_node("Camera/ParentView")
