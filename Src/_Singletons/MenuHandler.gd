extends Node
\
\
\
\
\
\
\
\
\
\
\
\
"\r\nPersonal note:\r\n\tAdding this directly into the PlayerChar node does not work.\r\n\tFor some reason it doesn't follow the player like any other player's child.\r\n\tWhatever global position it has in the MENU scene, it will have the same\r\n\tglobal position as the PLAYING scene.\r\n\t\r\n\tPlacing the script inside a Canvaslayer works, though, so now it can follow the player.\r\n\tI'll keep that in mind.\r\n\t\r\n\tNext time, for UI elements dedicated to the player, just have the same structure as this,\r\n\texcept it is placed inside as a player child rather than as a singleton.\r\n"










signal menu_changed

enum MENU_LEVEL{
	NONE, 
	MAIN, 
	PAUSE, 
	START, 
	JOIN, 
	OPTIONS, 
	TAB, 
	EXTRA, 
	RESTART, 
	SPECIAL_START, 
}

var menus = {
	MENU_LEVEL.MAIN: preload("res://Src/Menu/MainPauseScreen.tscn").instance(), 
	MENU_LEVEL.PAUSE: preload("res://Src/Menu/MainPauseScreen.tscn").instance(), 
	MENU_LEVEL.START: null, 
	MENU_LEVEL.JOIN: null, 
	MENU_LEVEL.OPTIONS: preload("res://Src/Menu/Options.tscn").instance(), 
	MENU_LEVEL.TAB: preload("res://Src/Menu/temp/tabOverlay.tscn").instance(), 
	MENU_LEVEL.EXTRA: preload("res://Src/Menu/Extra.tscn").instance(), 
	MENU_LEVEL.RESTART: preload("res://Src/Menu/RestartScreen.tscn").instance(), 
	MENU_LEVEL.SPECIAL_START: null, 
	MENU_LEVEL.NONE: null, 
}

func _ready():
	set_pause_mode(PAUSE_MODE_PROCESS)


func _input(event):
	if event.is_action_pressed("ui_tab") and not Globals.get_player() == null:
		if not is_current_menu(MENU_LEVEL.TAB) and not get_tree().paused:
			load_menu(MENU_LEVEL.TAB)


var current_menu_level: int = 0
var current_menu: Node = null
var current_scene




func is_current_menu( var menu_enum) -> bool:
	return true if current_menu_level == menu_enum else false


func load_menu(menu_level, received_scene_path = "") -> void :
	_add_to_current_scene(received_scene_path)
	call_deferred("_deferred_load_menu", menu_level)


func _add_to_current_scene(scene_path) -> void :
	if scene_path != "" and scene_path != null:
		current_scene = get_node(scene_path)

	
	
	
	else:
		if self.has_node("CanvasLayer"):
			current_scene = get_node("CanvasLayer")
		else:
			var canvas = CanvasLayer.new()
			canvas.set_name("CanvasLayer")
			canvas.layer = 100
			self.add_child(canvas)
		
			current_scene = canvas



func _deferred_load_menu(menulevel) -> void :
	current_menu = menus[menulevel]
	current_menu_level = menulevel

	if current_menu == null:
		pass
		
	var container

	if current_scene.has_node("menu"):
		container = current_scene.find_node("menu", false, false)
	else:
		var menunode = Node.new()
		menunode.set_name("menu")
		current_scene.add_child(menunode)

		container = menunode
	
	for location in container.get_children():
		container.remove_child(location)

	if current_menu != null and is_instance_valid(current_menu):
		container.add_child(current_menu)
	
		

	emit_signal("menu_changed")



\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
"\r\n@Bug\r\n@Refactor\r\n\r\n2021-04-29 18-00-00\r\n\r\nEncountered a problem. If you free a scene with a menu as its child, \r\nthat menu gets freed as well. When MenuHandler tries calling for that\r\nmenu, it will return [Deleted Object]. This happens frequently when \r\nswitching to another level while a menu is open.\r\n\r\nSide stepping the problem by just creating a new instance. This is more \r\nexpensive when calling for heavy menus, since I'm instancing it \r\nevery time the menu is called.\r\n\r\nThe original script assumes (to my understanding) that the menus are \r\nremoved or not present when the scene is freed, so if the menu is \r\nin a scene, then it's going to die with it.\r\n\r\nUPDATE 2021-04-29 18-50-43:\r\nApparently I'm just a moron. The reason buttons weren't registering was because\r\nCanvasLayer was conflicting with another CanvasLayer (Which was playerUI.\r\nGo figure.) \r\n\r\nI'm now going to use the MenuHandler as the current_scene instead.\r\n\r\nUPDATE 2021-04-29 19-00-45:\r\nOr I could've just changed SceneChanger pause setting from process \r\nto inherit. I'm a double, triple A moron.\r\n\r\nThings I should've done:\r\n - IF I'M TIRED, DON'T EVEN START BUGFIXING. \r\n - Written down the process of how the program runs.\r\n - Pinpoint the exact problem, and localize that problem. \r\n\t\tE.g., I thought MenuHandler was the problem, but my focus should've\r\n\t\tbeen on SceneChanger.\r\n - Creating a bunch of instances without freeing increases static memory,\r\n   \t\tessentially did memory leaks.\r\n\r\nSome great things to come from this:\r\n - Buttons can be used on Singletons. The CanvasLayer just needs to \r\n\t\tbe in a unique layer to avoid conflicts.\r\n - Buttons in different CanvasLayers can still be pressed, as long as\r\n\t\tthe CanvasLayer's layers are unique\r\n - Made sure that menus in MenuHandler will NEVER be freed accidentally \r\n\t\tbecause they live in a singleton.\r\n\t\tAlthough, I recognize that this might bite me later on, but at least\r\n\t\tI can just safely remove said menu.\r\n"
