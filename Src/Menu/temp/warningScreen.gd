extends Node2D



export (Resource) var scene_path_to_load
export (Resource) var mainhub
export (String) var scene_path_to_load_2 = "res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn"
export (String) var scene_path_to_load_3 = "res://Src/1_World/1_zones/ship/Stage_05-Canals.tscn"

func _ready():
	$message / Label.set_text(Globals.game_version)
	Pause.set_allow_pause(false)
	var thing = scene_path_to_load



func _process(delta):
	if Input.is_action_just_pressed("ui_enter") or Input.is_action_just_pressed("ui_t"):
		if Globals.is_entered_mainhub:
			Globals.is_show_mainhub_start_screen = true
			get_node("/root/SceneChanger")._change_scene(mainhub.get_path())
		else:
			get_node("/root/SceneChanger")._change_scene(scene_path_to_load.get_path())

	elif Input.is_action_just_pressed("ui_esc"):
		get_tree().quit()


func _on_quick_start_pressed():
	get_node("/root/SceneChanger")._change_scene(scene_path_to_load_3)
	$message / quick_start.release_focus()


func _on_debug_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/debugArena.tscn")
	$message / quick_start.release_focus()


func _on_warehouse_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn")
	$message / quick_start.release_focus()


func _on_theatre_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MallZones/Stage_01_a-TheatreHall.tscn")
	$message / quick_start.release_focus()


func player_skipped():
	EventManager.link_to_target("res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn", "lockedDoor", true)

