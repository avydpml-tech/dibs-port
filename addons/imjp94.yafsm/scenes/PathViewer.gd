tool 
extends HBoxContainer

signal dir_pressed(dir, index)


func _init():
	add_dir("root")


func back():
	return select_dir(get_child(max(get_child_count() - 1 - 1, 0)).name)


func select_dir(dir):
	for i in get_child_count():
		var child = get_child(i)
		if child.name == dir:
			remove_dir_until(i)
			return get_dir_until(i)


func add_dir(dir):
	var button = Button.new()
	button.name = dir
	button.flat = true
	button.text = dir
	add_child(button)
	button.connect("pressed", self, "_on_button_pressed", [button])
	return button


func remove_dir_until(index):
	var to_remove = []
	for i in get_child_count():
		if index == get_child_count() - 1 - i:
			break
		var child = get_child(get_child_count() - 1 - i)
		to_remove.append(child)
	for n in to_remove:
		remove_child(n)
		n.queue_free()


func get_cwd():
	return get_dir_until(get_child_count() - 1)


func get_dir_until(index):
	var path = ""
	for i in get_child_count():
		if i > index:
			break
		var child = get_child(i)
		if i == 0:
			path = "root"
		else:
			path = str(path, "/", child.text)
	return path

func _on_button_pressed(button):
	var index = button.get_index()
	var dir = button.name
	emit_signal("dir_pressed", dir, index)
