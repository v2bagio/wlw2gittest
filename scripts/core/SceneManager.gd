extends Node

var current_scene: Node = null

func change_scene(scene_path: String):
	var root = get_tree().root
	for child in root.get_children():
		if child != self:
			child.queue_free()
	var new_scene = load(scene_path).instantiate()
	root.add_child(new_scene)
	current_scene = new_scene

func reload_scene():
	if current_scene:
		change_scene(current_scene.scene_file_path)
	
