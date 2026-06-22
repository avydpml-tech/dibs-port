extends CanvasLayer

export (String, FILE) var test

func _ready():
	pass

func _clear_current_pos_location():
	PosManager.curr_start_pos = ""

func player_skipped():
	_clear_current_pos_location()
	EventManager.link_to_target("res://Src/1_World/1_zones/ship/Stage_09-Warehouse.tscn", "lockedDoor", true)





















func _on_debug_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/RightSuites/Stage-suiteLevel1.tscn")
	

func _on_club_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/LewdZones/Stage_02-StripedClub.tscn")

func _on_mainhub_pressed():
	_clear_current_pos_location()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn")

func _on_theatre_pressed():
	player_skipped()

	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MallZones/Stage_01_a-TheatreHall.tscn")

func _on_mall_pressed():
	player_skipped()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MallZones/Stage_02_b-Mall.tscn")


func _on_meetup_pressed():
	player_skipped()
	Achievements.start_koubold_and_wolf_miniquest()
	get_node("/root/SceneChanger")._change_scene("res://Src/1_World/1_zones/MainHub/Stage-Mainhub.tscn")

	pass
