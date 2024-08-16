extends Area2D
@onready var outer_parent = get_parent().get_parent().get_parent()
@onready var outer_scene = get_parent().get_parent()
@onready var inner_parent = get_parent()
@onready var inner_scene = self
@onready var previous_level = null
@export var entered: bool = false


func _change_parent(object, new_parent) -> void:
	object.get_parent().remove_child(object)
	new_parent.add_child(object)

func _set_current_level(current, proposed, body) -> void:
	var root = current.get_parent()
	if proposed.get_parent() != null:
		proposed.get_parent().remove_child(proposed)
	current.get_parent().remove_child(current)
	root.add_child(proposed)
	_change_parent(body, proposed)

func _get_current_level() -> Node:
	var root := get_tree().root
	return root.get_child(0)

func enter(body: CharacterBody2D) -> void:
	_set_current_level(_get_current_level(), inner_scene, body)
	entered = true

func exit(body: CharacterBody2D) -> void:
	_set_current_level(_get_current_level(), outer_scene, body)
	inner_parent.add_child(inner_scene)
	entered = false

# SIGNALS

func _on_body_entered(body):
	if not entered:
		call_deferred("enter", body)

func _on_body_exited(body):
	if entered:
		call_deferred("exit", body)
