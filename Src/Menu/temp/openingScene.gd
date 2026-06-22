extends Node2D


export (Resource) var scene_path_to_load
export (String) var scene_path_to_load_2 = "res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn"
export (String) var scene_path_to_load_3 = "res://Src/1_World/1_zones/ship/Stage_05-Canals.tscn"
export (Resource) var quick_start
export (Resource) var warehouse
export (Resource) var cinema
export (Resource) var mall


onready var ggsBool3 = $Control2 / MarginContainer / VBoxContainer / ggsBool3
onready var shortcuts = $Control2 / shortcuts / more_options
onready var shortcut_label = $Control2 / shortcuts / Label

func _ready():
	Pause.set_allow_pause(false)
	SoundManager.stop_music()
	Globals.reset()
	SaveManager.save_global()
	SaveManager.init()

func _input(event):
	if event.is_action_pressed("ui_t"):
		shortcuts.visible = not shortcuts.visible
		shortcut_label.visible = not shortcut_label.visible

	
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"))\
	and $Control2 / MarginContainer / VBoxContainer2.get_focus_owner() == null:
		$Control2 / MarginContainer / VBoxContainer2 / PlayButton.call_deferred("grab_focus")

	if event is InputEventMouseMotion:
		CursorManager.set_visible(true)

	
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"))\
	and $Control2 / MarginContainer / VBoxContainer.get_focus_owner() == null\
	and $Control2 / MarginContainer / VBoxContainer.visible:
			$Control2 / MarginContainer / VBoxContainer / ggsBool.call_deferred("grab_focus")

	if $Control2 / MarginContainer / VBoxContainer.visible and event.is_action_pressed("ui_cancel"):
		_on_BackButton_pressed()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_Button3_pressed():
	get_tree().quit()


func _exit_tree():
	Pause.set_allow_pause(true)


func _on_PlayButton_pressed():
	Globals.reset_everything()
	get_node("/root/SceneChanger")._change_scene(scene_path_to_load.get_path())


func _on_mall_pressed():
	player_skipped()
	Globals.reset_everything()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MallZones/Stage_02_b-Mall.tscn")


func _on_OptionsButton_pressed():
	$Control2 / MarginContainer / VBoxContainer2.hide()
	$Control2 / MarginContainer / VBoxContainer.show()
	ggsBool3.set_text(SettingsManager.keyboard_layout)


func _on_ggsBool3_pressed():
	ggsBool3.set_text(SettingsManager.keyboard_layout)


func _on_BackButton_pressed():
	$Control2 / MarginContainer / VBoxContainer2.show()
	$Control2 / MarginContainer / VBoxContainer.hide()


func _on_quick_start_pressed():
	get_node("/root/SceneChanger")._change_scene(scene_path_to_load_3)


func _on_debug_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/debugArena.tscn")

func _on_warehouse_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn")


func _on_theatre_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MallZones/Stage_01_a-TheatreHall.tscn")


func player_skipped():
	EventManager.link_to_target("res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn", "lockedDoor", true)


func _on_moxieButton_pressed():
	OS.shell_open("https://www.patreon.com/user?u=34316216")
