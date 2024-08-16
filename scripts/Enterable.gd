extends Area2D
@onready var outer_parent = get_parent().get_parent().get_parent()
@onready var outer_scene = get_parent().get_parent()
@onready var inner_parent = get_parent().get_parent()
@onready var inner_scene = get_parent()
@onready var previous_level = null
@export var entered: bool = false

func _set_current_level(current, proposed, body) -> void:
	var root = current.get_parent()
	if proposed.get_parent() != null:
		proposed.get_parent().remove_child(proposed)
	current.get_parent().remove_child(current)
	root.add_child(proposed)
	current.remove_child(body)
	proposed.add_child(body)

func _get_current_level() -> Node:
	var root := get_tree().root
	return root.get_child(0)

func enter(body: CharacterBody2D) -> void:
	if not entered:
		_set_current_level(_get_current_level(), inner_scene, body)
		entered = true

func exit(body: CharacterBody2D) -> void:
	if entered:
		_set_current_level(_get_current_level(), outer_scene, body)
		entered = false

# SIGNALS

func _on_body_entered(body):
	call_deferred("enter", body)

func _on_body_exited(body):
	# call_deferred("exit", body)
	pass
