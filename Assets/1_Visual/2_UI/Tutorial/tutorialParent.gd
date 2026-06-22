extends Sprite

export (String) var input_str = "ui_TEMP"
export (Array) var was_pressed = []
export (bool) var is_unaffected_by_one_handed = false
export (bool) var hide_when_exit_scene = false
export (bool) var hide_if_one_handed = false

var has_anim_played = false
var was_seen: bool = false

func _ready():
	set_visibility()
	SettingsManager.connect("one_handed_mode_set", self, "set_visibility")

	if Globals.tutorial_icons.empty():
		return

	var temp
	if Globals.tutorial_icons.has(get_owner().get_filename()):
		temp = Globals.tutorial_icons[get_owner().get_filename()]

		if get_name() in temp:
			queue_free()


func set_visibility():
	if is_unaffected_by_one_handed: return
	if hide_if_one_handed:
		hide() if SettingsManager.is_one_handed_mode else show()
	else:
		hide() if not SettingsManager.is_one_handed_mode else show()





func _input(event):
	if has_anim_played or not was_seen: return

	if hide_when_exit_scene:
		_put_in_globals()
		return

	if event.is_action_pressed(input_str):
		fade_icon()

	if was_pressed == []: return
	
	
	for pressed_key in was_pressed:
		if event.is_action_pressed(pressed_key):
			was_pressed.erase(pressed_key)

			if was_pressed == []:
				fade_icon()


func _put_in_globals():
	if Globals.tutorial_icons.empty()\
	or not Globals.tutorial_icons.has(get_owner().get_filename()):
		Globals.tutorial_icons[get_owner().get_filename()] = [get_name()]
	else:
		var temp_arr = Globals.tutorial_icons[get_owner().get_filename()]
		temp_arr.append(get_name())


func fade_icon():
	$AnimationPlayer.play("fade_out")
	has_anim_played = true
	_put_in_globals()


func _on_VisibilityNotifier2D_screen_entered():
	was_seen = true
