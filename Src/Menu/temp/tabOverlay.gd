extends Control

export (Resource) var tape_icon = null

onready var tape_icons = $tapeIcons / tapeIconsActive







var tapes_arr
var _state_switcher: bool = true







func _ready():
	MenuHandler.connect("menu_changed", self, "_show_tape_icons")
	MenuHandler.connect("menu_changed", self, "_update_buttons")
	MenuHandler.connect("menu_changed", self, "_update_stats")
	Achievements.connect("tape_picked_up", self, "_update_tape_icons")
	Achievements.connect("snack_found", self, "_show_snack_icons")
	Achievements.connect("snack_given", self, "_show_snack_icons")
	Achievements.connect("scarf_found", self, "_show_scarf_icon")
	Achievements.connect("scarf_given", self, "_show_scarf_icon")
	Achievements.connect("plant_cleared", self, "_update_stats")
	Achievements.connect("dutiful_citizen_fulfilled", self, "_update_stats")
	Achievements.connect("janitor_achieved", self, "_update_stats")
	Achievements.connect("achievements_reset", self, "_update_stats")
	Globals.connect("walk_area_entered", self, "_on_mouse_exit_mouse_entered")
	Globals.connect("hotkey_mode_pressed", self, "_update_buttons", [])

	

	
	
	hide_thumbnail()
	_spawn_all_tape_icons()
	_show_tape_icons()
	_show_snack_icons()
	_show_scarf_icon()
	_update_stats()


func _input(event):
	if event.is_action_pressed("ui_tab"):
		$AnimationPlayer.play("slide_out")


func close_tab_menu():
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.NONE)
	


func _spawn_all_tape_icons():
	tapes_arr = Achievements.completed_tapes
	var tape_idx: int = 0
	var num_columns: int = 2
	var num_rows: int = len(tapes_arr) / num_columns

	for i in range(num_rows):
		for j in range(num_columns):
			_spawn_tape_icon(i, j, tape_idx)
			tape_idx += 1

	
	var remainder = len(tapes_arr) % num_columns
	if remainder == 0: return
	for j in range(remainder):
		_spawn_tape_icon(num_rows, j, tape_idx)
		tape_idx += 1


func _spawn_tape_icon(row, column, tape_idx):
	var sprite = TextureButton.new()
	sprite.set_name(tapes_arr[tape_idx])
	sprite.texture_normal = tape_icon
	sprite.rect_position.x = 90 + (76 * column)
	sprite.rect_position.y = 86 + (85 * row)
	sprite.rect_scale = Vector2(1.5, 1.5)
	sprite.modulate = Color("ffffff")
	sprite.connect("mouse_entered", self, "show_thumbnail", [tapes_arr[tape_idx]])
	sprite.connect("mouse_exited", self, "hide_thumbnail")
	tape_icons.add_child(sprite)
	
	var sprite_bg = sprite.duplicate()
	sprite_bg.modulate = Color("414141")
	$tapeIcons / tapeIconsBG.add_child(sprite_bg)

	sprite.hide()


func show_thumbnail( var tape_name: String):
	$tapeIcons / tapeThumbnail.show()
	$tapeIcons / tapeThumbnail.play(tape_name)


func hide_thumbnail():
	$tapeIcons / tapeThumbnail.hide()









func _show_tape_icons():
	
	if not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB):
		return

	if not Achievements.collected_tapes == []:
		for icon in tape_icons.get_children():
			icon.hide()

	_update_tape_icons()
	$AnimationPlayer.play("slide_in")




func _update_tape_icons(_signal_catcher = null):
	for icon in tape_icons.get_children():
		if icon.get_name() in Achievements.collected_tapes:
			icon.show()

	for icon in tape_icons.get_children():
		if not icon.get_name() in Achievements.collected_tapes:
			icon.hide()


func _show_snack_icons():
	if not Achievements.is_snack_empty():
		$tapeIcons / Snack.show()
	else:
		$tapeIcons / Snack.hide()


func _show_scarf_icon():
	if Achievements.is_scarf_found and not Achievements.is_scarf_given:
		$tapeIcons / SneakScarf.show()
	else:
		$tapeIcons / SneakScarf.hide()


func _update_buttons(setting = "", boolean_value = false):
	if not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB):
		return

	for button in $FadeInGroup / Hotkeys / buttons.get_children():
		if button is CheckButton:
			button.update_button_status()


func _update_stats():
	var updated_text = Achievements.get_stats_string()
	$FadeInGroup / StatsGroup / Stats.text = updated_text







































	























	












	





var is_quick_access_open: bool = false
func _on_mouse_enter_mouse_entered():
	if is_quick_access_open: return
	is_quick_access_open = true
	$FadeInGroup / Hotkeys / AnimationPlayer.play("slide_in")


func _on_mouse_exit_mouse_entered():
	if not is_quick_access_open: return
	is_quick_access_open = false
	$FadeInGroup / Hotkeys / AnimationPlayer.play_backwards("slide_in")



func _on_click_avoider_mouse_entered():
	if is_quick_access_open:
		Globals.is_in_tab_buttons = true


func _on_click_avoider_mouse_exited():
	Globals.is_in_tab_buttons = false




func _on_fileReportButton_mouse_entered():
	
	$FadeInGroup / Node / fileReportButton.grab_focus()


func _on_fileReportButton_mouse_exited():
	$FadeInGroup / Node / fileReportButton.release_focus()

func _on_fileReportButton_pressed():
	if not Globals.get_player().player_state == "idle": return
		
	MenuHandler.load_menu(MenuHandler.MENU_LEVEL.RESTART)
	get_tree().paused = true

