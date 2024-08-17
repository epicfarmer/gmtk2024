extends Area2D
@onready var outer_parent = get_parent().get_parent().get_parent()
@onready var outer_scene = get_parent().get_parent()
@onready var inner_parent = get_parent()
@onready var inner_scene = self
@onready var previous_level = null
@export var entered: bool = false
var epsilon: float = 0.1

# @onready var ray: RayCast2D = get_node("/root/OuterLevel/RayCast2D")

func _change_parent(object, new_parent, new_position) -> void:
	object.get_parent().remove_child(object)
	new_parent.add_child(object)
	object.position = new_position

func _set_current_level(current, proposed, proposed_parent, body) -> void:
	var ray = RayCast2D.new()
	current.add_child(ray)
	ray.global_position = body.global_position
	ray.target_position = body.velocity
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	ray.hit_from_inside = true
	var counter = 0
	while (counter <= 10) and not ray.is_colliding():
		ray.position = ray.position + ray.to_local(proposed_parent.position) * epsilon
		ray.force_raycast_update()
		counter = counter + 1
	var tmp = ray.get_collider()
	var collision_global_position = ray.get_collision_point()
	var new_position = proposed.to_local(collision_global_position)
	print(new_position)
	print_debug(new_position)
	# ray.free()
	
	var root = current.get_parent()
	if proposed.get_parent() != null:
		proposed.get_parent().remove_child(proposed)
	current.get_parent().remove_child(current)
	root.add_child(proposed)
	_change_parent(body, proposed, new_position)

func _get_current_level() -> Node:
	var root := get_tree().root
	return root.get_child(0)

func enter(body: CharacterBody2D) -> void:
	_set_current_level(_get_current_level(), inner_scene, inner_parent, body)
	entered = true

func exit(body: CharacterBody2D) -> void:
	_set_current_level(_get_current_level(), outer_scene, outer_parent, body)
	inner_parent.add_child(inner_scene)
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
