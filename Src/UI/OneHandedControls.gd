extends Control

func _ready():
	SettingsManager.connect("one_handed_deadzone_set", self, "_set_deadzone")
	Globals.connect("joy_controller_activated", self, "disable_one_handed_mode", [])
	_set_deadzone()

	if Globals.has_game_started and not Globals.is_using_controller:
		check_if_mouse_in_move_areas()
	else:
		Globals.has_game_started = true





func _on_leftMouseArea_mouse_entered():
	if SettingsManager.is_one_handed_mode and not Globals.is_using_controller:
		Globals.walk_area_entered()
		Globals.walk_area_entered_left()
		get_owner().one_handed_movement = - 1


func _on_rightMouseArea_mouse_entered():
	if SettingsManager.is_one_handed_mode and not Globals.is_using_controller:
		Globals.walk_area_entered()
		Globals.walk_area_entered_right()
		get_owner().one_handed_movement = 1


func _on_rightMouseArea_mouse_exited():
	if SettingsManager.is_one_handed_mode and not Globals.is_using_controller:
		Globals.walk_area_exited_right()
		get_owner().one_handed_movement = 0


func _on_leftMouseArea_mouse_exited():
	if SettingsManager.is_one_handed_mode and not Globals.is_using_controller:
		Globals.walk_area_exited_left()
		get_owner().one_handed_movement = 0


func disable_one_handed_mode(is_using_conroller):
	if is_using_conroller:
		get_owner().one_handed_movement = 0


func _set_deadzone():
	var deadzone_value: int = SettingsManager.one_handed_deadzone

	$leftMouseArea.rect_size.x = 408
	$rightMouseArea.rect_position.x = 874

	$leftMouseArea.rect_size.x += deadzone_value
	$rightMouseArea.rect_position.x -= deadzone_value





func check_if_mouse_in_move_areas():
	if not SettingsManager.is_one_handed_mode: return

	var mouse_pos = get_global_mouse_position()
	var is_in_left = $leftMouseArea.get_rect().has_point(mouse_pos)
	var is_in_right = $rightMouseArea.get_rect().has_point(mouse_pos)

	get_owner().one_handed_movement = - int(is_in_left) + int(is_in_right)
