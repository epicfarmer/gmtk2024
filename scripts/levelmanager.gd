extends Node

@export_dir var level_dir_name = "res://levels"


var levels = ["res://levels/Level0.tscn","res://levels/Level1.tscn","res://levels/Level2.tscn","res://levels/Level3.tscn","res://levels/Level9.tscn"]

var current_level = "res://levels/Level0.tscn"

func _ready():
	# Pull all levels from `level_dir_name` and start the first one.
	# This will just quit to menu if the levels aren't found for whatever reason
	# Levels are loaded in alphabetical order
	#_populate_levels()
	current_level = levels[0]
	#restart()
#	var root = get_tree().root

func _populate_levels():
	# Populate the levels variable by reading all files in the levels directory
	# Levels are ordered alphabetically
	var level_dir = DirAccess.open(level_dir_name)
	if level_dir:
		level_dir.list_dir_begin()
		var level_path = level_dir.get_next()
		while level_path != "":
			if "Inner" not in level_path:
				levels.append(level_dir_name + "/" + level_path)
			level_path = level_dir.get_next()
	if len(levels) == 0:
		push_error("Failed to load any levels.")
	levels.sort()
	print(levels)

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
