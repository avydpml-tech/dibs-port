extends Interactable

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
"\r\nWhat this does:\r\n\tDoors transfer the player from scene to scene. \r\n\tThey do this by giving a 'scene's path' variable\r\n\tto a SceneChanger singleton.\r\n\t\r\n\tIn addition, it also changes where the player will be loaded\r\n\tin the next scene using preplaced positions. It is given a \r\n\tvalue, and the Position Manager (PosManager) will place the \r\n\tplayer in the position of the same name.\r\n\t\r\n\tNOTE: I made the exit point as a child of the door so it looks nicer. \r\n\t(and less cluttered.)\r\n\t\r\n\tSome limitations: If you ever need to change your project structure, \r\n\tthen good luck since you have to restructure your 'scene_path' for\r\n\tall your doors now.\r\n"

export (String, "default", "light", "long_door") var door_type = "default"
export (bool) var door_active = true
export (String) var scene_path_to_load = ""
export (String) var where_is_exit_point = ""
export (bool) var can_be_lit = false
export (bool) var enable_sound = true
export (bool) var turn_off_music = false
export (bool) var door_open = false
export (String) var unique_id = "generic"


func _ready():
	add_to_group("Interactable")
	add_to_group("Doors")
	if not unique_id in [null, "", "generic"]:
		add_to_group(unique_id)

	if door_open:
		$doorWithNoLights / AnimationPlayer.play("door_left_open")
	set_door_lights()


func interacted():
	if not door_active:
		$locked.play()
		return
		
	if $timeDelay.is_stopped():
		$timeDelay.start()
		_stop_player()
		_transport_player()
		_door_open_visuals()
		ItemManager.call_deferred("parse_for_ammo_in_scene")


func _transport_player():
	PosManager.pass_scene_properties(where_is_exit_point, get_owner())
	get_node("/root/SceneChanger").call_deferred("_change_scene", scene_path_to_load)
	if enable_sound:
		SoundManager.call_deferred("play_bsfx", "door")
	_turn_off_music()


func _interacted_by_obj():
	door_active = true
	set_door_lights()


func _interacted_by_EventManager(variant):
	_interacted_by_obj()


func _on_clickToEnter_pressed():
	print("Clicked")
	interacted()
	pass


func _door_open_visuals():
	if door_open: return
	$doorWithNoLights / AnimationPlayer.play("open_door")
	$doorWithLights / AnimationPlayer.play("open_door")
	$longDoor / AnimationPlayer.play("open_door")


func _door_close_visuals():
	if door_open: return
	$doorWithNoLights / AnimationPlayer.play("close_door")
	$doorWithLights / AnimationPlayer.play("close_door")
	$longDoor / AnimationPlayer.play("close_door")





func set_door_lights():
	$doorWithLights.hide()
	$doorWithNoLights.hide()
	$longDoor.hide()

	match (door_type):
		"default": $doorWithNoLights.show()
		"light": $doorWithLights.show()
		"long_door": $longDoor.show()

	var boolean = can_be_lit and door_active
	$Lights.visible = boolean
	$doorWithLights.visible = boolean


func _turn_off_music():
	if turn_off_music:
		SoundManager.stop_music()


func _stop_player():
	pass


func _on_VisibilityNotifier2D_screen_exited():
	pass


func _on_VisibilityNotifier2D_screen_entered():
	pass


func _on_detectPlayerNear_body_entered(body: Node):
	if body.get_name() == "playerChar"\
	and not $isPlayeronDoorTimer.is_stopped()\
	and not door_open:
		_door_close_visuals()


func scene_path_is_not_save_station( var scene: String) -> bool:
	return true if scene == "res://1_World/1_zones/ship/Stage-SaveStation.tscn" else false



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
"\r\n###################################################################\r\n\r\n\t: Dramatic demonstration by Professor Dave :\r\n\t\r\n\t!!! --- What shouldn't happen --- !!!\r\n\t\t=== Scene 1 is instanced ===\r\n\t\t\r\n\t\t Point A         7_O_/  ay       Point D         \r\n\t\t|                 (/     ay     | \r\n\t\t|                 //'          |\r\n\t\t|                 7             |\r\n\t\t\r\n\t\tPlayer is spawed in between Point A and Point B.\r\n\t\tPlayer enters Point A. When we go to Scene 2, we should\r\n\t\tbe near Point B.\r\n\t\t\r\n\t\t=== Scene 2 is instanced ===\r\n\t\t\r\n\t\t Point C  7_O_/  oh              Point B         \r\n\t\t|          (/     no            | \r\n\t\t|          //'                 |  \r\n\t\t|          7                    |\r\n\t\t\r\n\t\tOh no indeed. Player spawned near Point C. \r\n\t\tWe left the player avatar near Point C in the scene \r\n\t\tand we don't have a way to control where player loads.\r\n\t\t\r\n\t\tHere's how to fix it.\r\n\t\t\r\n\t\tMeet the position point.  |>> + <<|\r\n\t\t\r\n\t\tWe just need to give the PosManager the position's\r\n\t\tname and let it take care of everything\r\n\t\t\r\n\t\t   \r\n\t~~~ --- What SHOULD happen --- ~~~\r\n\t\t=== Scene 1 is instanced ===\r\n\t\t\r\n\t\t Point A    7_O_/  right         Point D         \r\n\t\t|            (/     right       | \r\n\t\t|            //'     ay        |\r\n\t\t|            7                  |\r\n\t\t\r\n\t\tPlayer enters Point A. \r\n\t\t\r\n\t\tThis time, we give PosManager the position's name of\r\n\t\twhere we expect to be in the next scene.\r\n\t\t\r\n\t\tWe want Point B, which is on the right side, \r\n\t\tso we give 'right' to PosManager.                \r\n\t\t\r\n\t\t=== Scene 2 is instanced ===\r\n\t\t\r\n\t\t Point C            7_O_/ nice   Point B         \r\n\t\t|                    (/    nice | \r\n\t\t|                    //'       |  \r\n\t\t+left                7          +right\r\n\t\t\r\n\t\tThere you go.\r\n"


