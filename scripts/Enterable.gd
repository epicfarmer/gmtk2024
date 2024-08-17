extends Area2D
@onready var outer_parent = get_parent().get_parent().get_parent()
@onready var outer_scene = get_parent().get_parent()
@onready var inner_parent = get_parent()
@onready var inner_scene = self
@onready var tmp_parent = $Viewport
@onready var previous_level = null
@export var entered: bool = false
var epsilon: float = 0.1
var outer_position_on_entry = null
var inner_position_on_entry = null

# @onready var ray: RayCast2D = get_node("/root/OuterLevel/RayCast2D")

func _change_parent(object, new_parent) -> void:
	object.get_parent().remove_child(object)
	new_parent.add_child(object)
	
func _new_raycast() -> RayCast2D:
	var ray = RayCast2D.new()
	ray.collide_with_areas = true
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	ray.hit_from_inside = true
	ray.collision_mask = 2
	return ray

func _instant_raycast(ray: RayCast2D, global_origin: Vector2, direction: Vector2, target: Area2D):
	ray.global_position = global_origin
	ray.target_position = direction
	ray.force_raycast_update()
	if ray.is_colliding():
		if ray.get_collider() == target:
			return ray.get_collision_point()
	return null
	
func _distance_squared(point_1: Vector2, point_2: Vector2) -> float:
	var squared_diff = (point_1 - point_2) * (point_1 - point_2)
	return squared_diff[0] + squared_diff[1]

func _aabb_raycast(ray: RayCast2D, global_origin_position: Vector2, target: Node2D):
	if _distance_squared(global_origin_position, target.global_position) < epsilon:
		push_warning("This should probably not happen")
		return global_origin_position
	var direction: Vector2 = target.global_position - global_origin_position
	var ray1 = _new_raycast()
	_get_current_level().add_child(ray1)
	var ray2 = _new_raycast()
	_get_current_level().add_child(ray2)
	var x_collision = _instant_raycast(ray1, global_origin_position, direction * Vector2(1, 0), target)
	var y_collision = _instant_raycast(ray2, global_origin_position, direction * Vector2(0, 1), target)
	var x_collided: bool = x_collision != null
	var y_collided: bool = y_collision != null
	if x_collided and y_collided:
		var x_distance = _distance_squared(x_collision, global_origin_position)
		var y_distance = _distance_squared(y_collision, global_origin_position)
		if x_distance <= y_distance:
			return x_collision
		return y_collision
	if x_collided:
		remove_child
		return x_collision
	if y_collided:
		return y_collision
	return _aabb_raycast(ray, (1 - epsilon) * global_origin_position + epsilon * target.global_position, target)


func _set_current_level(current, proposed, proposed_parent, body) -> void:	
	var root = current.get_parent()
	if proposed.get_parent() != null:
		proposed.get_parent().remove_child(proposed)
	current.get_parent().remove_child(current)
	root.add_child(proposed)
	_change_parent(body, proposed)

func _get_current_level() -> Node:
	var root := get_tree().root
	return root.get_child(0)
	
func _set_body_position_enter(body) -> void:
	var ray = _new_raycast()
	_get_current_level().add_child(ray)
	var collision_global_position = _aabb_raycast(ray, body.global_position, self)
	_get_current_level().remove_child(ray)
	var new_position = inner_scene.to_local(collision_global_position)
	body.position = new_position

func enter(body: CharacterBody2D) -> void:
	outer_position_on_entry = body.position
	_set_body_position_enter(body)
	_set_current_level(_get_current_level(), inner_scene, inner_parent, body)
	inner_position_on_entry = body.position
	var viewport: SubViewport = tmp_parent.get_node("SubViewport")
	viewport.add_child(outer_scene)
	viewport.render_target_update_mode = 4
	entered = true

func wait(seconds) -> void:
	await get_tree().create_timer(10).timeout

func exit(body: CharacterBody2D) -> void:
	var local_end = body.position
	_set_current_level(_get_current_level(), outer_scene, outer_parent, body)
	var inner_global_end = inner_parent.to_global(local_end)
	body.position = outer_scene.to_local(inner_global_end)
	inner_parent.add_child(inner_scene)
	wait(10)
	entered = false

# SIGNALS

func _on_body_entered(body):
	if not entered:
		call_deferred("enter", body)
		print("Entering")

func _on_body_exited(body):
	if entered:
		call_deferred("exit", body)
		print("Exiting")
