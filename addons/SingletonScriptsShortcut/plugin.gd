tool 
extends EditorPlugin

var editorInterface = get_editor_interface()
var scriptEditor = editorInterface.get_script_editor()
var scriptEditorMenu = scriptEditor.get_child(0).get_child(0)




const sceneShortcutExt = preload("res://addons/SingletonScriptsShortcut/shortcutext.tscn")
var shortcutext

func _enter_tree():
	
	
	
	
	shortcutext = sceneShortcutExt.instance()
	
	scriptEditorMenu.add_child(shortcutext)
	scriptEditorMenu.move_child(shortcutext, scriptEditorMenu.get_child_count() - 10)
	
	shortcutext.connect("request_items", self, "update_shortcuts")
	shortcutext.itemlist.connect("item_activated", self, "index_pressed")
	
	
	update_shortcuts(shortcutext.find_node("ItemList"))

func _exit_tree():
	
	if is_instance_valid(shortcutext): shortcutext.queue_free()
	
	
	

func update_shortcuts(itemlist, tog = true):
	itemlist.clear()
	var currentScript = ""
	if scriptEditor.get_current_script() != null:
		currentScript = scriptEditor.get_current_script().get_path()
	
	shortcutext.add_singletons(getListOfSingletons(), self, currentScript, tog)




func index_pressed(idx):
	var scriptPath = shortcutext.itemlist.get_item_metadata(idx)
	editorInterface.edit_resource(load(scriptPath))
	shortcutext.popup.hide()

func getListOfSingletons():
	var dictionary = {}
	var list = ProjectSettings.get_property_list()
	for i in list:
		if i.name.begins_with("autoload"):
			var scriptPath = ProjectSettings.get_setting(i.name)
			if scriptPath.begins_with("*"): scriptPath = scriptPath.right(1)
			if scriptPath.begins_with("res://") == false: scriptPath = "res://" + scriptPath
			if scriptPath.ends_with(".gd") == false: scriptPath = scriptPath.get_basename() + ".gd"
			dictionary[i.name.trim_prefix("autoload/")] = scriptPath
	return dictionary
