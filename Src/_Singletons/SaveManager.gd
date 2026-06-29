extends Node











signal game_saved

func _ready():
	load_global()
	
	if Globals.is_entered_mainhub:
		load_player()
		load_all_files()

	if Globals.connect("entered_mainhub", self, "enable_saving") != OK:
		pass

	_create_version_txt()


func enable_saving():
	if Globals.is_entered_mainhub:

		
		if not SceneChanger.is_connected("scene_changed", self, "attempt_save"):
			if SceneChanger.connect("scene_changed", self, "attempt_save") != OK:
				pass


func _exit_tree():
	save_global()


func init():
	check_if_settings_outdated()
	easter_egg_file()






func attempt_save():
	if SettingsManager.is_autosave:
		save_all_data()


func save_all_data():
	var player_dict = Globals.save_player_to_file()
	var entity_list = EntityManager.persistent_entity_list
	var achievements = Achievements.save()
	var events = EventManager.save()
	var items = ItemManager.save()

	save_to_persist("player", player_dict)
	save_to_persist("entity", entity_list)
	save_to_persist("achievement", achievements)
	save_to_persist("event", events)
	save_to_persist("item", items)

	emit_signal("game_saved")


func save_achievements():
	var achievements = Achievements.save()
	save_to_persist("achievement", achievements)


func save_to_persist(filename, data_arr):
	var dir = Directory.new()
	if dir.make_dir("user://persist") == OK:
		pass

	var file_dir = "user://persist/" + filename
	var json_string = JSON.print(data_arr)

	var file = File.new()
	if file.open(file_dir, File.WRITE) == OK:
		file.store_string(json_string)
		file.close()


func save_global():
	save_to_persist("global", Globals.save())






func load_player():
	Globals.load_player_data(load_file("player"))


func load_global():
	var global_file_content = load_file("global")
	Globals.load_data(global_file_content)


func load_all_files():
	var achievement_file_content = load_file("achievement")
	var event_file_content = load_file("event")
	var entity_file_content = load_file("entity")
	var item_file_content = load_file("item")

	Achievements.load_data(achievement_file_content)
	EventManager.load_data(event_file_content)
	EntityManager.persistent_entity_list = entity_file_content if entity_file_content != null else []
	ItemManager.load_data(item_file_content)




func load_file(filename):
	var file_dir = "user://persist/" + filename

	var file = File.new()
	if file.open(file_dir, File.READ) == OK:
		var json_string = file.get_as_text()

		var save_dict = JSON.parse(json_string).result
		file.close()

		return save_dict

	print_debug("Failed to open file")
	return null






func check_if_settings_outdated():
	var dir = Directory.new()
	if not dir.file_exists("user://version.txt"):
		create_new_settings()

	
	var file = File.new()
	if file.open("user://version.txt", File.READ) == OK:
		var contents = file.get_as_text().strip_edges()
		file.close()

		if ProjectSettings.get_setting("application/config/version") != contents:
			create_new_settings()


func create_new_settings():
	var dir = Directory.new()

	dir.open("user://")
	dir.remove("settings_data.json")
	dir.remove("version.txt")

	
	var file = File.new()
	file.open("user://version.txt", File.WRITE)
	file.store_line(Globals.game_version)
	file.close()


func easter_egg_file():
	var data = \
\
\
\
\
\
	"Wait, there's save files now. Neat.\n\tHere, an owl for your diligence. \n\n\t  (o,o)   coo.\n\t <  .  >\n\t---\"-\"--- \n\t\t- M"
	var path = "user://no_save_files_yet.txt"
	var file: File = File.new()
	var err: int = file.open(path, File.WRITE)
	if err == OK:
		file.store_string(data)
		file.close()


func _create_version_txt():
	
	var file = File.new()
	file.open("user://version.txt", File.WRITE)
	file.store_line(Globals.game_version)
	file.close()
