@tool
extends EditorScript

var total = 0

func _run():
	_scan_dir("res://scenes")
	print("Sprites de fundo marcados: ", total)

func _scan_dir(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		var full_path = path + "/" + file_name
		if dir.current_is_dir():
			_scan_dir(full_path)
		elif file_name.ends_with(".tscn"):
			_mark_scene(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func _mark_scene(path: String):
	var scene = load(path)
	if scene == null:
		return
	var root = scene.instantiate()
	var changed = false
	for child in root.get_children():
		if child is Sprite2D and not child.is_in_group("fundo_sprite"):
			child.add_to_group("fundo_sprite")
			total += 1
			changed = true
	if changed:
		var packed = PackedScene.new()
		packed.pack(root)
		ResourceSaver.save(packed, path)
		print("Marcado: ", path)
	root.queue_free()
