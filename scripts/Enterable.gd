extends Area2D
@onready var outer_parent
@onready var outer_scene
@onready var inner_parent
@onready var inner_scene
@onready var tmp_parent
@onready var previous_level
var entering: bool = false
var exiting: bool = false
var inside: bool = false
var epsilon: float = 0.1
var outer_position_on_entry = null
var inner_position_on_entry = null

# @onready var ray: RayCast2D = get_node("/root/OuterLevel/RayCast2D")
func _ready():
	previous_level = null
	inner_scene = self
	inner_parent = get_parent()
	outer_scene = inner_parent.get_parent()
	if outer_scene != null:
		outer_parent = outer_scene.get_parent()
		tmp_parent = $Viewport

func _change_parent(object, new_parent) -> void:
	object.get_parent().remove_child(object)
	new_parent.add_child(object)

func _set_current_level(current, proposed, proposed_parent, body) -> void:	
	if current == proposed:
		return
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
	var ray = AABBRayCast2D.new()
	_get_current_level().add_child(ray)
	var collision_global_position = ray._aabb_raycast(body.global_position, self)
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
	inside = true

func wait(seconds) -> void:
	await get_tree().create_timer(seconds).timeout
	
func exit(body: CharacterBody2D) -> void:
	var local_end = body.position
	_set_current_level(_get_current_level(), outer_scene, outer_parent, body)
	var inner_global_end = inner_parent.to_global(local_end)
	body.position = outer_scene.to_local(inner_global_end)
	inner_parent.add_child(inner_scene)
	inside = false

# SIGNALS

func _on_body_entered(body):
	if body.can_enter_or_exit:
		body.on_enter_or_exit()
		call_deferred("enter", body)
		print("Entering")

func _on_body_exited(body):
	if body.can_enter_or_exit:
		body.on_enter_or_exit()
		call_deferred("exit", body)
		print("Exiting")
