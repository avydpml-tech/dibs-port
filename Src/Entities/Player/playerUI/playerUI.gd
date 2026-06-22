extends Control





export (Resource) var ammo_img_4
export (Resource) var ammo_img_3
export (Resource) var ammo_img_2
export (Resource) var ammo_img_1
export (Resource) var clickable_ammo
export (NodePath)onready var denied_ammo_fade_component = get_node(denied_ammo_fade_component) as Node
export (bool) var display_fps = true
export (bool) var display_debug = false

onready var player
onready var mags = $mags

var ui_mag_arr = []
var max_mag_count: int = 0

func _ready():
	$staminaBar.hide()
	$snackProgressBar.hide()
	for p in get_tree().get_nodes_in_group("Player"):
		player = p
		max_mag_count = p.max_mag_count
	connect_signals()
	has_stamina_shown = false
	_show_shoe()
	_turn_stamina_blue()
	_show_debug_label()
	call_deferred("create_magazine_sprites")
	_update_magazine_sprites()


func connect_signals():
	if Globals.get_player().connect("tape_found", self, "_show_tape_found_message") != OK:
		print_debug(self, ": ERROR. Signal tape_found not connected to _show_tape_found_message")
	if Globals.get_player().connect("tired_boss_denied", self, "_fade_heartbeat_denied_ammo") != OK:
		print_debug(self, ": ERROR. Signal tired_boss_denied not connected to _fade_heartbeat_denied_ammo")
	
	if Achievements.connect("snack_found", self, "_show_snack_found_message") != OK:
		print_debug(self, ": ERROR. Signal snack_found not connected to _show_snack_found_message")
	if Achievements.connect("dutiful_citizen_fulfilled", self, "_show_achievement_got_message") != OK:
		print_debug(self, ": ERROR. Signal dutiful_citizen_fulfilled not connected to _update_stats")
	if Achievements.connect("scarf_found", self, "_show_scarf_found") != OK:
		print_debug(self, ": ERROR. Signal scarf_found not connected to _show_scarf_found")
	if Achievements.connect("newspaper_found", self, "_show_newspaper_found") != OK:
		print_debug(self, ": ERROR. Signal newspaper_found not connected to _show_newspaper_found")
	if Globals.get_player().connect("stamina_depleted", self, "player_coom_ready") != OK:
		print_debug(self, ": ERROR. stamina_depleted not connected to player_coom_ready")
	if SaveManager.connect("game_saved", self, "play_loading_anim") != OK:
		print_debug(self, ": ERROR. game_saved not connected to play_loading_anim")
	
	
	player.connect("stamina_full", self, "stamina_filled")
	player.connect("stamina_empty_jump", self, "_play_stamina_empty_jump")
	SettingsManager.connect("sfw_mode_set", self, "_show_shoe")
	SettingsManager.connect("bored_mode_set", self, "_turn_stamina_blue")
	Achievements.connect("janitor_achieved", self, "_show_plants_achievement_got_message")
	Globals.connect("hotkey_mode_pressed", self, "_alert_setting_change", [])




func _process(_delta):
	display_magazine_sprites(player.magazine_arr.size())
	_update_magazine_sprites()

	_should_show_stamina(abs(player.stamina) >= 95)
	set_snack_progress()
	set_alert_setting_change_visibility()
	$Loading / noAutoSave.visible = not SettingsManager.is_autosave


func set_snack_progress():
	$snackProgressBarTest.visible = not Achievements.is_snack_empty()

	var time_left = Globals.get_snack_timer().time_left
	var wait_time = Globals.get_snack_timer().wait_time

	
	
	$snackProgressBarTest.value = (wait_time - time_left) / wait_time * 100

	$snackProgressBarTest.modulate = "57a9d3ef" if $snackProgressBarTest.value >= 100 else "19a9d3ef"





func _alert_setting_change(setting, boolean_value):
	
	var text = "Exploration Mode" if setting == "exploration_mode" else "Bored Mode"
	text += " Enabled" if boolean_value else " Disabled"
	$PopupText.set_text(text)

func set_alert_setting_change_visibility():
	$PopupText.visible = not MenuHandler.is_current_menu(6)






var stamina_just_reached_zero: bool = false
var is_already_ending: bool = false






var stamina_anim_has_played = false

var has_stamina_shown = true
onready var stamina_fade_anim = $staminaBar / AnimationPlayer2
onready var snack_fade_anim = $snackProgressBar / AnimationPlayer2

func _should_show_stamina(boolean):
	if boolean and has_stamina_shown:
		stamina_fade_anim.play("show_to_hide")
		snack_fade_anim.play("show_to_hide")
		has_stamina_shown = false

	if not boolean and not has_stamina_shown:
		$staminaBar.show()
		$snackProgressBar.show()
		
		
		
		
		stamina_fade_anim.play_backwards("show_to_hide")
		snack_fade_anim.play_backwards("show_to_hide")
		has_stamina_shown = true


func update_stamina_bar(stamina_float):
	$staminaBar / leftStaminaBar.value = stamina_float
	$staminaBar / rightStaminaBar.value = stamina_float
	
	
	$staminaBar / BlueHeart.visible = (player.stamina_rate_percentage != 1)


func stamina_filled():
	if SettingsManager.is_bored_mode and player.player_state == "saucied":
		player_coom_ready()


func _turn_stamina_blue():
	$staminaBar.modulate = "#92cfff" if SettingsManager.is_bored_mode else "#ffffff"
	$snackProgressBar.modulate = "#92cfff" if SettingsManager.is_bored_mode else "#ffffff"
	
	var stamina_anim = $staminaBar / AnimationPlayer2.get_animation("show_to_hide")
	var stamina_idx = stamina_anim.find_track(".:modulate")

	var snack_anim = $snackProgressBar / AnimationPlayer2.get_animation("show_to_hide")
	var snack_idx = stamina_anim.find_track(".:modulate")

	if SettingsManager.is_bored_mode:
		stamina_anim.track_set_key_value(stamina_idx, 0, "#92cfff")
		snack_anim.track_set_key_value(snack_idx, 0, "#92cfff")
	else:
		stamina_anim.track_set_key_value(stamina_idx, 0, "#ffffff")
		snack_anim.track_set_key_value(snack_idx, 0, "#ffffff")


func player_coom_ready():
	
	if SettingsManager.is_bored_mode and \
	not player.player_state in ["saucied", "grappled"]\
	and not is_already_ending:
		EndingsManager.start_ending("bored")
		is_already_ending = true
		return

	if not player.player_state == "saucied": return
	if stamina_just_reached_zero: return


	print(self, ": Stamina reached zero. Coom ready")
	$coomButton._on_playerChar_coom_ready()
	stamina_just_reached_zero = true


func play_stamina_danger_anim():
	if not $staminaBar / AnimationPlayer.is_playing() and not stamina_anim_has_played:
		$staminaBar / AnimationPlayer.play("danger")
		stamina_anim_has_played = true


func play_stamina_danger_anim_backwards():
	if not $staminaBar / AnimationPlayer.is_playing() and stamina_anim_has_played:
		$staminaBar / AnimationPlayer.play_backwards("danger")
		stamina_anim_has_played = false


func _play_stamina_empty_jump():
	$exclaimPopup.restart()
	$exclaimPopup.emitting = true





func spawn_coom_button():
	if player.player_state == "idle":
		$coomButton.visible = false
	elif player.player_state == "saucied":
		$coomButton.visible = true
		$coomButton.saucy_start()
		print_debug(Globals.new_timestamp(), "CoomButton: CoomButton started")








func create_magazine_sprites():
	for i in range(max_mag_count):
		var sprite = Sprite.new()
		var sprite_scale = 2.2
		var sprite_distance = 35
		
		sprite.texture = ammo_img_4
		sprite.scale = Vector2(sprite_scale, sprite_scale)
		sprite.position = Vector2(sprite_distance * i, 20)
		sprite.set_rotation_degrees(15)
		sprite.hide()

		mags.add_child(sprite)
		sprite.name = "magazine" + str(i)
		
		
		
		
	ui_mag_arr = mags.get_children()






func _update_magazine_sprites():
	for i in range(player.magazine_arr.size()):
		var ammo_amount: int = player.magazine_arr[i]
		
		match ammo_amount:
			6, 7: ui_mag_arr[i].texture = ammo_img_3
			5, 4: ui_mag_arr[i].texture = ammo_img_2
			3, 2, 1: ui_mag_arr[i].texture = ammo_img_1
			_: ui_mag_arr[i].texture = ammo_img_4


func display_magazine_sprites( var curr_mag_cnt: int = 0):
	for mag in ui_mag_arr:
		var index = mag.get_index()
		
		var last_mag = floor(curr_mag_cnt - 1)
		if index > last_mag:
			mag.hide()
		elif index <= last_mag:
			mag.show()





func _show_tape_found_message():
	$popup / AnimationPlayer.play("tape_found")
	$popup / tapeFoundAudio.play()

func _show_snack_found_message():
	$popup / AnimationPlayer.play("snack_found")
	$popup / tapeFoundAudio.play()

func _show_achievement_got_message():
	$popup / AnimationPlayer.play("dutiful_citizen_achievement")
	$popup / tapeFoundAudio.play()

func _show_plants_achievement_got_message():
	$popup / AnimationPlayer.play("plants_cleared_achievement")
	$popup / tapeFoundAudio.play()

func _show_scarf_found():
	$popup / AnimationPlayer.play("scarf_found")
	$popup / tapeFoundAudio.play()

func _show_newspaper_found():
	$popup / AnimationPlayer.play("newspaper_found")
	$popup / tapeFoundAudio.play()







func _on_dropMagButton_pressed():
	Globals.get_player().drop_extra_mag()


func _show_shoe():
	$shoes.visible = SettingsManager.is_sfw_mode
	$shoes / AnimationPlayer.play("shoe")



func show_player_stuck_label():
	$debugLabel2.show()
	pass

func hide_player_stuck_label():
	$debugLabel2.hide()
	pass


func show_one_handed_enabled():
	$OneHandReminder.show()
	pass

func hide_one_handed_enabled():
	$OneHandReminder.hide()
	pass


func _show_debug_label():
	if not display_debug:
		$debugLabel.hide()
	else:
		$debugLabel.show() if OS.has_feature("debug") else $debugLabel.hide()


func play_loading_anim():
	$Loading / AnimationPlayer.play("loading")


func _fade_heartbeat_denied_ammo():
	if denied_ammo_fade_component:
		denied_ammo_fade_component.fade_heartbeat()
	else:
		printerr(self.get_name(), ": There is no fade component.")