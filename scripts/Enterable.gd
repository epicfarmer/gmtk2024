extends Area2D
var outer_parent
var outer_scene
var inner_parent
var inner_scene
var tmp_parent
var previous_level


var entering: bool = false
var exiting: bool = false
var inside: bool = false
var epsilon: float = 0.1

var to_unfreeze_on_entry: Array[EnteringBody]

# @onready var ray: RayCast2D = get_node("/root/OuterLevel/RayCast2D")
func _ready():
	previous_level = null
	inner_scene = self
	inner_parent = get_parent()
	outer_scene = inner_parent.get_parent()
	if outer_scene != null:
		outer_parent = outer_scene.get_parent()

func _change_parent(object, new_parent) -> void:
	object.get_parent().remove_child(object)
	new_parent.add_child(object)

func _set_current_level(current, proposed) -> void:	
	if current == proposed:
		return
	var root = current.get_parent()
	if proposed.get_parent() != null:
		proposed.get_parent().remove_child(proposed)
	current.get_parent().remove_child(current)
	root.add_child(proposed)
	OS.delay_msec(1000)

func _get_current_level() -> Node:
	var root := get_tree().root
	return root.get_child(1)

func _get_entering_body(body) -> EnteringBody:
	return body.get_node("EnteringBody")
	
func _set_body_position_enter(body) -> void:
	var ray = AABBRayCast2D.new()
	_get_current_level().add_child(ray)
	var collision_global_position = ray._aabb_raycast(body.global_position, self)
	_get_current_level().remove_child(ray)
	var new_position = inner_scene.to_local(collision_global_position)
	body.position = new_position
	body.scale = Vector2.ONE

func enter(body: CollisionObject2D) -> void:
	if _get_current_level() == inner_scene:
		return
	_set_body_position_enter(body)
	if _get_entering_body(body).has_camera:
		tmp_parent = _get_entering_body(body).get_parent_view()
		if tmp_parent == null:
			push_error("Null parent")
		_get_current_level().disable_boundary()
		_set_current_level(_get_current_level(), inner_scene)
		for entering_body in to_unfreeze_on_entry:
			print("Here")
			entering_body.unfreeze_body()
	else:
		var entering_body: EnteringBody = _get_entering_body(body)
		to_unfreeze_on_entry.push_back(entering_body)
		entering_body.freeze_body()
	_change_parent(body, inner_scene)
	if _get_entering_body(body).has_camera:
		var viewport: SubViewport = tmp_parent.get_node("SubViewport")
		viewport.add_child(outer_scene)
		inside = true
		enable_boundary()
	OS.delay_msec(300)

func wait(seconds) -> void:
	await get_tree().create_timer(seconds).timeout
	
func exit(body: CollisionObject2D) -> void:
	if _get_current_level() == outer_scene:
		return
	var local_end = body.position
	if _get_entering_body(body).has_camera:
		disable_boundary()
		_set_current_level(_get_current_level(), outer_scene)
	_change_parent(body, outer_scene)
	if _get_entering_body(body).has_camera:
		inner_parent.add_child(inner_scene)
		inside = false
		_get_current_level().enable_boundary()
	var inner_global_end = inner_parent.to_global(local_end)
	body.position = outer_scene.to_local(inner_global_end)
	OS.delay_msec(300)

func disable_boundary():
	var exit_bound = get_node("./exit_boundary")
	if exit_bound != null:
		exit_bound.visible = false

func enable_boundary():
	var exit_bound = get_node("./exit_boundary")
	if exit_bound != null:
		exit_bound.visible = true
	
# SIGNALS

func _on_body_entered(body):
	var entering_body: EnteringBody = _get_entering_body(body)
	if entering_body.can_enter_or_exit:
		entering_body.on_enter_or_exit()
		call_deferred("enter", body)
		print("Entering")

func _on_body_exited(body):
	var entering_body: EnteringBody = _get_entering_body(body)
	if entering_body.can_enter_or_exit:
		entering_body.on_enter_or_exit()
		call_deferred("exit", body)
		print("Exiting")
		
