extends Node

@export_dir var level_dir_name = "res://levels"


var levels = [
	"res://levels/Level1.tscn",
	"res://levels/outer_level.tscn"
]

var current_scene = null
var current_level = "res://levels/Level1.tscn"

func _ready():
	var level_dir = DirAccess.open(level_dir_name)
	if level_dir:
		level_dir.list_dir_begin()
		var level_path = level_dir.get_next()
		while level_path != "":
			print(level_path)
			levels.append(level_path)
			level_path = level_dir.get_next()
		current_level = levels[0]
	restart()
#	var root = get_tree().root
#	current_scene = root.get_child(root.get_child_count() - 1)

func restart():
	goto_scene(current_level)
	
func next_level():
	var ind = levels.find(current_level)
	current_level = levels[ind + 1]
	goto_scene(current_level)
	

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)
	AudioManager.start()


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	var root = get_tree().root
	var current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	if s != null:
		current_scene = s.instantiate()
	else:
		go_to_menu()
		return

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

func go_to_menu():
	get_tree().quit()
