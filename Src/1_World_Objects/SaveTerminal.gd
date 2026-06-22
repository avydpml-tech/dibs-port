extends StaticBody2D


func _ready():
	add_to_group("Interactable")

func interacted():
	pass





\
\
\
\
\
\
\
"\r\nNOTE: These save functions only work if it is not a nested Persist\r\n\t  Object (i.e, Persist object that is a child of another persist Object).\r\n\t  Otherwise, it will return 'file not found''\r\n''\t\r\nOk, on Windows ' user:// ' is in the appdata folder.\r\n''\r\n"
var save_dir = "res://saves/savegame.save"
var win_save_dir = "user://saves/savegame.save"

func save_game():
	var save_game = File.new()
	save_game.open(save_dir, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		var node_data = i.call("save");
		save_game.store_line(to_json(node_data))
	save_game.close()


func load_game():
	var save_game = File.new()
	if not save_game.file_exists(save_dir):
		return

	
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
		
	
	save_game.open(save_dir, File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if current_line == null:
			break

		
		var new_object = load(current_line["filename"]).instance()
		get_node(current_line["parent"]).add_child(new_object)
		new_object.position = Vector2(current_line["pos_x"], current_line["pos_y"])
		
		
		for i in current_line.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, current_line[i])
	save_game.close()
