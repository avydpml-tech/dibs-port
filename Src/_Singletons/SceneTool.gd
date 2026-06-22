extends Node

const LEVELS_FILE_PATH = "res://levels.dat"
var current_scene = null

func _ready():
	SceneChanger.connect("scene_changed", self, "set_current_scene")
	SceneChanger.connect("scene_changed", self, "update_text")
	set_current_scene()
	update_text()

	
	$VBoxContainer / HBoxContainer / AddButton.connect("pressed", self, "store_entry")
	$VBoxContainer / HBoxContainer / AddButton.connect("pressed", self, "update_text", [], CONNECT_DEFERRED)
	$VBoxContainer / HBoxContainer / AddButton.connect("pressed", $VBoxContainer / HBoxContainer / AddButton, "release_focus")


func _input(event):
	if event.is_action_pressed("ui_left_mouse"):
		$VBoxContainer / HBoxContainer / LineEdit.release_focus()


func store_entry():
	var scene_dictionary = {
		"scene": get_tree().get_current_scene().filename, 
		"tag": $VBoxContainer / HBoxContainer / OptionButton.text, 
		"tag_info": $VBoxContainer / HBoxContainer / LineEdit.text, 
	}
	var scene_dict_to_string = JSON.print(scene_dictionary)

	remove_old_entries(scene_dictionary["scene"])
	save(scene_dict_to_string)
	
	$VBoxContainer / HBoxContainer / LineEdit.text = ""





func set_current_scene():
	current_scene = get_tree().get_current_scene().filename


func get_scene_array():
	var array = []
	for scene_dictionary_string in load_file().split("\n"):
		if scene_dictionary_string == "":
			continue
		array.append(JSON.parse(scene_dictionary_string).result)
	return array


func update_text():
	var text = "[color=red]Level not saved.[/color]"
	
	
	for scene_dictionary in get_scene_array():
		if not scene_dictionary["scene"] == get_tree().get_current_scene().filename:
			continue

		if scene_dictionary["tag"] == "map_item":
			text = "[color=green]Level is in map: " + scene_dictionary["tag_info"] + "[/color]"
		else:
			text = "[color=blue]Level has special screen: " + scene_dictionary["tag"] + "[/color]"

	$VBoxContainer / RichTextLabel.bbcode_text = text



func remove_old_entries(scene: String):
	var saved_scene_array = get_scene_array()
	var should_replace: = false

	for scene_dictionary in saved_scene_array:
		if not scene_dictionary["scene"] == get_tree().get_current_scene().filename:
			continue
		else:
			should_replace = true

	if should_replace:
		
		var dir = Directory.new()
		dir.remove(LEVELS_FILE_PATH)

		
		for scene_dictionary in saved_scene_array:
			if not scene_dictionary["scene"] == get_tree().get_current_scene().filename:
				save(JSON.print(scene_dictionary))

		print("deleted entries")





func save(content: String):
	var file = File.new()

	
	if not file.file_exists(LEVELS_FILE_PATH):
		file.open(LEVELS_FILE_PATH, File.WRITE)

	
	file.open(LEVELS_FILE_PATH, File.READ_WRITE)
	file.seek_end(0)
	file.store_line(content)
	file.close()


func load_file():
	var file = File.new()
	file.open(LEVELS_FILE_PATH, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

