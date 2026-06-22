









extends Entity
class_name PlayerChar









signal player_grappled
signal player_grapple_freed
signal player_fired
signal tape_found

signal tired_boss_denied
signal set_state(state)





export (bool) var show_debug = false
export (String, "idle", "sit") var starting_state
export (int) var max_health: int = 3
export (bool) var is_tangled = false
export (bool) var interact_in_groups = false
export (float) var disable_saucy_sec = 2.5
export (int) var max_speed = 450
export (int) var max_jump_height = - 550
export (int) var max_ammo_count = 9
export (int) var max_mag_count = 3
export (int) var jump_stamina_penalty = 7
export (int) var coom_count: int = 0
export (int, 500) var idle_timer: int = 30
export (float, 0.1, 3) var time_to_reload = 1.7
export (float, 0.0, 1.0) var hold_reload_combine_threshold = 0.3
export (float, 6) var bullet_spread = 6
export (float, 2) var bullet_spread_time = 1.5
export (float, 1) var camera_saucy_zoom = 0.7
export (float, 1) var default_camera_zoom = 0.9
export (float, 2) var stamina_recover_time = 1.5
export (float) var jump_buffer_time = 0.3
export (Array, int) var magazine_arr = [6, 3, 7]
export (String) var Separator = "==================="
export (Resource) var max_health_sheet
export (Resource) var health_2_sheet
export (Resource) var health_1_sheet
export (Resource) var health_0_sheet
export (Resource) var teleport_sound
export (Resource) var ammo_PackedScene
export (Resource) var debug_overlay
export (Resource) var debug_locations_overlay
export (Resource) var last_known_position_node
export (float) var bored_time = 420


onready var light_player = $visualNodes / playerLight / lightPlayer
onready var saucy_speed_timer = $Timers / saucySpeedTimer
onready var reload_tap_timer = $Timers / reloadTapTimer
onready var disable_saucy_timer = Timer.new()
onready var reload_timer = Timer.new()
onready var reset_jump_height_timer = Timer.new()
onready var bullet_spread_timer = Timer.new()
onready var fire_delay = Timer.new()
onready var invul_timer = Timer.new()
onready var parent = get_parent()
onready var player_ui = $UI / playerUI
onready var reticle_pos = $visualNodes / playerAim / playerReticlePos


onready var player_sprite = $playerSprite
onready var player_sprite_anim = $playerSprite / playerSpriteAnimPlayer
onready var player_tangle_sprite = $tangleSprite
onready var player_tangle_anim = $tangleSprite / AnimationPlayer
onready var vignette_anim = $visualNodes / playerVignette / AnimationPlayer
onready var player_light_anim = $visualNodes / playerLight / lightPlayer
onready var saucy_sprite_anim = $saucySprite / SaucyAnimationPlayer
onready var knock_back_range = $detectArea / knockBackRange

var Nonplayer
var current_health: int = 1
var ammo_count: int = 0
var disable_saucy_time_left = 0

var who_saucied = ["walnut"]
var day_or_night = "night"
var curr_day_or_night = null
var jump_height = - 550
var anim_state_machine = null
var afterglow_count = null
var being_saucied: bool = false
var return_to_idle: bool = false
var new_dir = "left"
var tangle_counter: int = 0
var tangle_max: int = 5
var owner_thing: String
var is_flashlight_enabled: bool = true
var is_blaster_enabled: bool = false
var is_player_input_disabled: bool = false
var control: Control = Control.new()

const PLAYER_PARTICLES = preload("../Player/playerProjectiles/playerParticle.tscn")
const PLAYER_PROJECTILE = preload("../Player/playerProjectiles/bulletProj.tscn")
const GRAPPLE_MECHANIC = preload("../Player/grappleMechanic/grapple_mechanic.tscn")







func _enter_tree():
	pass
		

func _ready():
	current_health = max_health
	move_speed = max_speed
	jump_height = max_jump_height
	dir = "right"

	$"UI/onScreenVersion".set_text("Is alpha big boys. " + Globals.game_version)
	
	
	Globals.load_player_global_variables()

	connect_to_audio_script()
	add_timers()
	player_clothes()
	_sort_magazines()
	set_state(starting_state)
	flashlight_visibility()
	connect_signals()
	
	if not is_connected("stamina_updated", player_ui, "update_stamina_bar"):
		connect("stamina_updated", player_ui, "update_stamina_bar")

	if not is_connected("stamina_depleted", self, "stamina_depleted_breath"):
		connect("stamina_depleted", self, "stamina_depleted_breath")
	
	if not is_connected("coom_ready", player_ui, "player_coom_ready"):
		connect("coom_ready", player_ui, "player_coom_ready")

	Globals.connect("blush_set", self, "set_blush")

	anim_state_machine = $playerSprite / AnimationTree.get("parameters/playback")
	$visualNodes / playerLight.energy = 0.01
	
	$visualNodes.show()
	$saucySprite.hide()
	$grappleSprites / playerGrappleSprite.hide()
	$grappleSprites / creatureGrappleSprite.hide()
	$grappleSprites / wolf.hide()

	
	
	saucy_shade_overlay_anim.get_parent().hide()

	if show_debug: call_deferred("add_debug_overlay")

	load_player_last_position()

	change_blaster_color(is_blaster_enabled)
	ScreenManager.normal_speed_fade()

	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")
	add_child(control)

	


func _on_focus_changed(control):
	pass



func load_player_last_position():
	var load_pos = last_known_position_node.instance()
	load_pos.player = self
	get_owner().call_deferred("add_child", load_pos)





func add_timers():
	add_timer("reload_timer")
	add_timer("down_delay_timer")
	add_timer("reset_jump_height_timer")
	add_timer("bullet_spread_timer")
	add_timer("fire_delay")
	reload_timer = get_node("reload_timer")
	reset_jump_height_timer = get_node("reset_jump_height_timer")
	bullet_spread_timer = get_node("bullet_spread_timer")
	fire_delay = get_node("fire_delay")
	
	add_child(disable_saucy_timer)
	add_child(pump_timer)
	disable_saucy_timer.one_shot = true

	bullet_spread_timer.wait_time = bullet_spread_time
	fire_delay.wait_time = 0.1

	reset_jump_height_timer.connect("timeout", self, "_on_reset_jump_height_timeout")
	disable_saucy_timer.start(disable_saucy_sec)



func add_debug_overlay():
	

	print_debug(self.get_name(), ": DebugOverlay instantiated")
	if has_node("DebugOverlay"): get_node("DebugOverlay").queue_free()
	if has_node("DebugLocationButtons"): get_node("DebugLocationButtons").queue_free()

	var overlay = debug_overlay.instance()
	var location_buttons = debug_locations_overlay.instance()

	overlay.add_stat("Player state", self, "player_state", false)
	overlay.add_stat("magazines", self, "magazine_arr", false)
	overlay.add_stat("current_health", self, "current_health", false)
	overlay.add_stat("disable_saucy_timer", self, "disable_saucy_time_left", false)
	overlay.add_stat("stamina", self, "stamina", false)
	overlay.add_stat("stamina_rate", self, "stamina_rate", false)
	overlay.add_stat("stamina_just_reached_zero", player_ui, "stamina_just_reached_zero", false)
	overlay.add_stat("stamine_rate_percentage", self, "stamine_rate_percentage", false)
	overlay.add_stat("has_stamina_shown", player_ui, "has_stamina_shown", false)
	overlay.add_stat("should_move", self, "should_move", false)
	overlay.add_stat("is_seated", self, "is_seated", false)
	overlay.add_stat("one_handed_movement", self, "one_handed_movement", false)
	overlay.add_stat("is_one_handed_mode", SettingsManager, "is_one_handed_mode", false)
	overlay.add_stat("collected_tapes", Achievements, "collected_tapes", false)
	overlay.add_stat("is_using_controller", Globals, "is_using_controller", false)
	overlay.add_stat("is_moving_joysticks", Globals, "is_moving_joysticks", false)
	overlay.add_stat("is_show_cursor", CursorManager, "is_show_cursor", false)
	overlay.add_stat("is_on_wall", self, "is_on_wall", true)
	overlay.add_stat("is_blaster_enabled", self, "is_blaster_enabled", false)

	add_child(overlay)
	add_child(location_buttons)


func _input(event):
	flashlight_visibility()
	if is_tangled:
		if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
			tangle_counter += 1

	
	if event.is_action_pressed("ui_flashlight")\
	and player_state in ["run", "jump", "idle", "fall"]\
	and is_flashlight_enabled\
	and SettingsManager.is_one_handed_mode\
	and control.get_focus_owner() == null\
	and not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB):
		self.flashlight_active = not flashlight_active
		if not flashlight_active:
			stopped_flashing_light()

	if event.is_action_pressed("ui_space") and is_flashlight_enabled:
		self.flashlight_active = not flashlight_active
		if not flashlight_active:
			stopped_flashing_light()

	
	
	if event.is_action_pressed("ui_F5"):
		show_debug = not show_debug
		if show_debug: add_debug_overlay()
		elif has_node("DebugOverlay"):
			get_node("DebugOverlay").queue_free()
			if has_node("DebugLocationButtons"):
				get_node("DebugLocationButtons").queue_free()

	if event.is_action_pressed("ui_j"):
		who_saucied = ["walnut", "hangmon", "shieldmon", "cordygreg", "ceiling_dweller", "tit_hugger", "umbrella", "noodle"]

	if (event.is_action_pressed("ui_g") or event.is_action_pressed("ui_f")) and show_debug:
		global_position = get_global_mouse_position()
		SoundManager.just_play_sound(teleport_sound)

	if show_debug:
		owner_thing = get_owner().get_filename()

	
	if event.is_action_pressed("ui_tab"):
		if MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB):
			disable_phone_idle_mox()

		if not MenuHandler.is_current_menu(MenuHandler.MENU_LEVEL.TAB) and player_state in ["idle"]:
			enable_phone_idle_mox()


	if event.is_action_released("ui_r")\
	and not reload_timer.is_stopped()\
	and not reload_timer_in_threshold():
		can_combine_ammo = false
		
		if not SettingsManager.is_auto_combine_ammo_mode:
			drop_mag()
		
		if is_in_reload_combine_threshold():
			_return_to_idle()

	
	
	
	if event.is_action_pressed("ui_z") and player_state == "saucy":
		_on_free_grapple(true)
		turn_continue_saucy_false()

	if event.is_action_pressed("ui_y"):
		if player_state != "disabled":
			emit_signal("set_state", "disabled")
		else:
			enable_mox()

	if event.is_action_pressed("ui_F10"):
		$playerSprite.visible = not $playerSprite.visible


func connect_signals():
	$ProgressBar.connect("timeout", self, "start_custom_afterglow")


func _process(_delta):
	set_can_jump()
	disable_saucy_time_left = disable_saucy_timer.time_left




func set_blush(blush_value):
	if blush_value:
		$blush.show()
	else:
		$blush.hide()


func mox_sat_down():
	pass


func mox_stood_down():
	pass





var stamina: float = 100 setget set_stamina
var stamina_rate = 5

export (int) var decrease_stamina_rate: int = 10

var stamina_rate_percentage

signal stamina_updated
signal stamina_depleted
signal stamina_full

func set_stamina(new_value):
	if stamina == new_value: return
	stamina = new_value
	

	
	
	
	
	

	if stamina < 5:
		call_deferred("emit_signal", "stamina_depleted")
		
		

	if stamina >= 95:
		call_deferred("emit_signal", "stamina_full")

	if stamina < 20:
		player_ui.play_stamina_danger_anim()
	else:
		player_ui.play_stamina_danger_anim_backwards()



func decrease_stamina(unique_rate = null):
	stamina -= (decrease_stamina_rate if unique_rate == null else unique_rate) * stamina_rate_percentage


func set_decrease_stamina_rate(percentage = null):
	stamina_rate_percentage = percentage

func add_stamina(new_value = null):
	stamina += new_value



func _update_stamina(delta):
	self.stamina += delta * stamina_rate
	stamina = clamp(stamina, 0, 100)
	emit_signal("stamina_updated", stamina)



func _on_staminaTimer_timeout():
	if SettingsManager.is_bored_mode: return
	if player_state in ["idle", "aim", "reload"]:
		stamina_rate = 30







func eat_snack():
	pass

func heal():
	stamina = 98
	
	Globals.start_snack_timer()

func _should_heal():
	if Achievements.is_snack_empty() or not $Timers / snackHealTimer.is_stopped():
		return

	if Input.is_action_pressed("ui_snack"):
		heal()
		$eatSnackAnim.play_anim()

func _on_snackHealTimer_timeout():
	pass




func _is_health_full():
	if (current_health) >= max_health: return true


func _add_health( var add_health: int):
	var new_health: int = current_health + add_health
	current_health = clamp(new_health, 0, max_health)
	player_clothes()

func _remove_clothes( var remove_health: int):
	var new_health: int = current_health - remove_health
	current_health = clamp(new_health, 0, max_health)
	player_clothes()


func player_clothes():
	update_coom_circles()
	match current_health:
		0:
			$playerSprite.set_texture(health_0_sheet)
			$backArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-backarm.png")
			$frontArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-frontarm.png")
			$visualNodes / suitFlashlight.enabled = false
		1:
			$playerSprite.set_texture(health_1_sheet)
			$backArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-backarm.png")
			$frontArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-frontarm.png")
		2:
			$playerSprite.set_texture(health_2_sheet)
			$backArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-backarm.png")
			$frontArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-frontarm.png")
		max_health:
			$playerSprite.set_texture(max_health_sheet)
			$backArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-separated-backarm.png")
			$frontArm.texture = load("res://Assets/1_Visual/1_Entities/!_player/Sprites/fox-character-aim-separated-arm.png")

		





onready var wall_checker = $visualNodes / playerAim / WallChecker
var random_bullet_spread = rand_range( - 5, 5)


func enable_blaster():
	is_blaster_enabled = true
	change_blaster_color(is_blaster_enabled)



func disable_blaster():
	is_blaster_enabled = false
	change_blaster_color(is_blaster_enabled)


func change_blaster_color(is_enabled):
	if is_enabled:
		
		self.material.set_shader_param("u_replacement_color", Color(0.305882, 0.305882, 0.305882))
	else:
		
		self.material.set_shader_param("u_replacement_color", Color(0.545098, 0.32549, 0.32549))





func check_blaster_light_state():
	if ammo_count <= 0 or not is_blaster_enabled:
		self.material.set_shader_param("u_tolerance", 0.258)
	else:
		self.material.set_shader_param("u_tolerance", 0.0)


func enable_phone_idle_mox():
	if anim_state_machine.get_current_node() != "idle": return
	anim_state_machine.travel("phone")


func disable_phone_idle_mox():
	if not is_disabled() and player_state in ["idle", "run", "jump"]:
		$playerSprite.show()
	$moxPhone.hide()


func stop_idle_timer():
	$Timers / idlePhoneTimer.stop()


func start_idle_timer():
	$Timers / idlePhoneTimer.start(idle_timer)
	$Timers / boredTimer.start(bored_time)


func _on_idlePhoneTimer_timeout():
	enable_phone_idle_mox()


func _on_boredTimer_timeout():
	EndingsManager.start_ending("idle")
	

func _player_attack():
	if len(wall_checker.get_overlapping_bodies()) > 0:
		print("PlayerChar: Player arm is blocked when aiming. Not firing.")
	else:
		_fire_projectile()
		emit_signal("player_fired")

	if not SettingsManager.is_infinite_ammo_mode:
		_deplete_ammo(1)


func _fire_projectile():
	var projectile = PLAYER_PROJECTILE.instance()
	var projectile_pos = $visualNodes / playerAim / playerProjectilePos
	var rot = projectile_pos.global_rotation
	var pos = projectile_pos.global_position
	
	
	var spread = (bullet_spread * bullet_spread_timer.time_left) / bullet_spread_time
	projectile.spread = spread
	projectile._start(pos, rot)
	get_owner().add_child(projectile)
	
	


func _start_bullet_spread_timer():
	pass
		

func _deplete_ammo( var ammo):
	ammo_count -= ammo
	




var is_most_ammo_first: bool = true
var can_combine_ammo: bool = true

func start_reload_timer():
	reload_timer.start(time_to_reload)
	reload_tap_timer.start()
	can_combine_ammo = true



func _reload():
	_sort_magazines()

	if can_combine_ammo or SettingsManager.is_auto_combine_ammo_mode:
		combine_mags()
		return

	ammo_count = magazine_arr.pop_front()


func _on_reloadTapTimer_timeout():
	pass


func reload_timer_in_threshold() -> bool:
	return true if reload_timer.time_left < 0.26 else false


func is_in_reload_combine_threshold() -> bool:
	var percentage = (reload_timer.wait_time - reload_timer.time_left) / reload_timer.wait_time
	var is_in_threshold: bool = percentage > hold_reload_combine_threshold

	return true if is_in_threshold else false







func replace_least_ammo_in_magazine_arr( var received_ammo):
	spawn_magazine(magazine_arr.pop_back())
	magazine_arr.append(received_ammo)
	_sort_magazines()




func is_ammo_in_magazine_arr_bigger( var received_ammo: int):
	for ammo_int in magazine_arr:
		if received_ammo > ammo_int:
			return false
	return true









func drop_mag():
	if ammo_count > 0:
		spawn_magazine(ammo_count)
		ammo_count = 0



func drop_extra_mag():
	if magazine_arr.size() != 0:
		spawn_magazine(magazine_arr.pop_back())
		_sort_magazines()


func add_mag( var received_ammo):
	if received_ammo <= 0: return

	if magazine_arr.size() + 1 <= max_mag_count:
		magazine_arr.append(received_ammo)
		_sort_magazines()


func _sort_magazines():
	magazine_arr.sort()
	if is_most_ammo_first:
		magazine_arr.invert()



func switch_ammo_sort_order():
	is_most_ammo_first = not is_most_ammo_first
	combine_mags()
	_sort_magazines()


func combine_mags():
	var sum: int = sum_array(magazine_arr) + ammo_count
	magazine_arr.clear()

	if sum < max_ammo_count:
		ammo_count = sum
		return

	
	for i in range(sum / max_ammo_count):
		add_mag(max_ammo_count)

	
	ammo_count = magazine_arr.pop_front()

	
	if magazine_arr.size() < max_mag_count:
		add_mag(sum % max_ammo_count)



func spawn_magazine( var ammo_count: int):
	if get_owner() != null:
		var ammo_inst = ammo_PackedScene.instance()
		ammo_inst.ammo_amount = ammo_count
		ammo_inst.is_temporary = true
		
		get_owner().add_child(ammo_inst, true)
		ammo_inst.set_owner(get_owner())
		ammo_inst.global_position = self.global_position + Vector2(0, - 10)
	else:
		print("PlayerChar: get_owner() is null. Cannot instance ammo")



func check_if_2_full_ammo() -> bool:
	if magazine_arr.size() < 2:
		return false

	for i in range(2):
		if magazine_arr[i] != 9:
			return false
	return true


func pop_front_mags(value = null):
	if value == null:
		magazine_arr = []
		return

	for i in range(value):
		magazine_arr.pop_front()


func is_magazine_arr_full( var _add_mag: int) -> bool:
	return false if not magazine_arr.size() == max_mag_count else true



static func sum_array(array) -> int:
	var sum = 0
	for element in array:
		sum += element
	return sum






var controller_weight_vec = Vector2(0, 0)
onready var aim_pos = $visualNodes / playerAim / playerProjectilePos
onready var aim_pos_reference = $visualNodes / playerAim / playerGunPointReference


func is_right_stick_active() -> bool:
	return true if not controller_weight_vec == Vector2(0, 0) else false






func _should_aim() -> bool:
	controller_weight_vec = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	if Input.is_action_pressed("ui_right_mouse"):
		return true
	elif Input.is_action_pressed("ui_aim"):
		return true
	elif is_right_stick_active():
		return true
	return false


func _player_aim(_condition):
	if not Globals.is_using_controller:
		$visualNodes / playerAim.look_at(get_global_mouse_position())
	elif is_right_stick_active():
		$visualNodes / playerAim.rotation = controller_weight_vec.angle()


func _pistol_sounds( var state):
	match state:
		"up": $Audio / aimUp.play()
		"down": $Audio / aimDown.play()
		"fire": $Audio / fire.play()
		"reload": $Audio / reload.play()
		"stop": $Audio / reload.stop()
		"dead_trigger": $Audio / deadTrigger.play()
		"deny_beep": $Audio / denyBeep.play()


var num_input: int = 1
func spawn_inst( var instance):
	get_parent().call_deferred("add_child", instance)
	instance.position = self.global_position





signal player_state_changed
signal player_dir_changed


var player_state = "" setget player_state_changed
					
					
					

func player_state_changed(new_state):
	if not is_connected("player_state_changed", player_ui, "spawn_coom_button"):
		connect("player_state_changed", player_ui, "spawn_coom_button")
	player_state = new_state
	emit_signal("player_state_changed")


func dir_changed(new_dir):
	dir = new_dir
	emit_signal("player_dir_changed")

func check_floor() -> bool:
	return true if $detectArea / checkFloor.is_colliding() or $detectArea / checkFloor2.is_colliding() else false
	













func nightTimeVignette():
	match day_or_night:
		"light": vignette_anim.play("vignette_fade")
		"bright": vignette_anim.play_backwards("vignette_fade")
		"dark": vignette_anim.play("dark")

		
		"night": vignette_anim.play("vignette_fade")
		"day": vignette_anim.play_backwards("vignette_fade")
		"slightly_dark": vignette_anim.play("slightly_dark")
		_: vignette_anim.play("vignette_fade")


func night_torch():
	
	match day_or_night:
		"light": light_player.play("torch_brighten")
		"dark": light_player.play("torch_brighten_more")
		"bright": light_player.play("torch_brighten_entire_area")
		
		
		"day": light_player.play("torch_bright")
		"night": light_player.play_backwards("torch_bright")
		"slightly_dark": player_light_anim.play("torch_bright_more")


onready var saucy_shade_overlay_anim = $visualNodes / CanvasLayer / ColorRect / AnimationPlayer
onready var saucy_shade_overlay = $visualNodes / CanvasLayer / ColorRect

func _saucy_vignette( var param = "default"):
	match param:
		"light": saucy_shade_overlay.color = 0
		"light_dark":
			saucy_shade_overlay.show()
			saucy_shade_overlay_anim.play("light_to_dark")
		"dark_light":
			saucy_shade_overlay_anim.play("dark_to_light")
			


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "dark_to_light":
		saucy_shade_overlay.hide()





onready var middle_flashlight_raycast = $visualNodes / playerAim / middleRaycast
onready var flashlight_area2D = $visualNodes / playerAim / middleFlashlight
onready var suit_flashlight = $visualNodes / suitFlashlight
onready var suit_flashlight_area = $visualNodes / suitFlashlight / suitFlashlight2

var flashlight_active: bool = true setget set_flashlight_active
var temp_flashlight: bool = false
var bodies_in_flashlight = []
var raycast_collider

func set_flashlight_active(value):
	flashlight_active = value



func flashlight(enable = true):
	is_flashlight_enabled = enable



func flashlight_aim( var aiming = false):
	var flashlight = $visualNodes / playerAim / flashlight
	flashlight.visible = aiming
	enable_flashlight_raycasts(aiming)


func flashlight_visibility():

	
	var states_no_flash_allowed = ["grappled", "saucied", "tangled", "afterglow", "sit"]
	var flashlight_player_state = not player_state in states_no_flash_allowed
	var should_suit_flash = flashlight_active and flashlight_player_state and current_health > 0
	
	suit_flashlight.enabled = should_suit_flash
	suit_flashlight_area.monitoring = should_suit_flash
	suit_flashlight.energy = 0.8 if day_or_night == "dark" else 0.6
	
	flashlight_icon(flashlight_player_state)


func flashlight_icon(flashlight_player_state = false):
	$UI / flashlight_icon_final.visible = flashlight_active if current_health > 0 else flashlight_player_state and flashlight_active

	var center_position = Vector2(640, 588.85)
	var side_position = Vector2(49.271, 588.85)
	$UI / flashlight_icon_final.position = side_position if current_health != 0 else center_position



func _check_flashlight_area2D():
	_is_flashing_Nonplayer(flashlight_area2D, true)
	pass


func _on_suitFlashlight2_body_exited( var body):
	if not flashlight_active: return

	if body.get_class() == "Nonplayer":
		body.not_flashed_anymore()
	if body.is_in_group("CanBeFlashed"):
		body.not_flashed_anymore()


func _check_suit_area2D():
	if flashlight_active:
		_is_flashing_Nonplayer($visualNodes / suitFlashlight / suitFlashlight2)




func _is_flashing_Nonplayer( var area, is_weapon_flashlight = false):
	if not area.monitoring: return
	for body in area.get_overlapping_bodies():
		if body.get_class() == "Nonplayer":
			if not body in bodies_in_flashlight:
				bodies_in_flashlight.append(body)
			body.flashed_by_flashlight()
		if body.is_in_group("CanBeFlashed") and is_weapon_flashlight:
			if not body in bodies_in_flashlight:
				bodies_in_flashlight.append(body)
			body.flashed_by_flashlight()



func enable_flashlight_raycasts(boolean: bool):
	raycast_collider = middle_flashlight_raycast.get_collider() if boolean else null
	
	if not boolean:
		flashlight_area2D.monitoring = false
		flashlight_area2D.visible = false
		
	elif raycast_collider != null and boolean:
		if raycast_collider.is_in_group("Nonplayer") or raycast_collider.is_in_group("CanBeFlashed"):
			flashlight_area2D.visible = true
			flashlight_area2D.monitoring = true




func stopped_flashing_light():
	
	for body in bodies_in_flashlight:
		if is_instance_valid(body):
			if body != null:
				if get_owner().has_node(body.get_path()):
					body.not_flashed_anymore()
					
				if body.is_in_group("CanBeFlashed"):
					body.not_flashed_anymore()
			if body.is_in_group("CanBeFlashed"):
				body.not_flashed_anymore()
	bodies_in_flashlight = []









			
func dir_manager(set_new_dir: bool = false):
	set_dir(set_new_dir)
	face_dir()
	suit_flashlight()


func suit_flashlight():
	
	if current_health < 0 or ( not player_state in ["grappled", "saucied", "tangled"]):
		suit_flashlight.rotation_degrees = 90 if dir == "right" else - 90
	else:
		$visualNodes / suitFlashlight.enabled = false


func dir_to_cursor_pos():
	if not Globals.is_using_controller:
		new_dir = "right" if global_position < get_global_mouse_position() else "left"
	else:
		new_dir = "right" if controller_weight_vec.x > 0 else "left"



func set_dir(_set_new_dir: bool = false):
	if is_right_stick_active():
		var controller_angle = controller_weight_vec.angle()
		
		if dir == "right"\
		and not (1.7 > controller_angle and controller_angle > - 1.93):
			
			setDir("left")
		if dir == "left"\
		and (1.5 > controller_angle and controller_angle > - 1.31):
			
			setDir("right")

	elif player_state == "aim":
		setDir(new_dir)
	else:
		if (Input.is_action_pressed("ui_right")\
		and Input.is_action_pressed("ui_left") == false):
			setDir("right")
		elif (Input.is_action_pressed("ui_left")\
		and Input.is_action_pressed("ui_right") == false):
			setDir("left")
		elif one_handed_movement:
			setDir("right") if one_handed_movement == 1 else setDir("left")


func face_dir():
	player_sprite.flip_h = dir == "left"


func _on_rightSide_area_entered(area):
	if area.get_name() == "cursorPos" and not is_right_stick_active():
		new_dir = "right"

func _on_leftSide_area_entered(area):
	if area.get_name() == "cursorPos" and not is_right_stick_active():
		new_dir = "left"
	









var mon_grappled_inst = null
var mon_grappled_name: String = ""
var entities_in_range = []
var should_fall_when_grappled: bool = false

var is_saucied_with_koubold: bool = false
var is_auto_saucy: bool = false

onready var floor_jump_checker_raycast = $detectArea / floorJumpChecker

var is_grappled: bool = false

signal set_grapple_state
signal set_idle_state


func _is_player_still_grappled() -> bool:
	if is_grappled:
		is_grappled = false
		return true
	return false


func fall_in_line(Nonplayer_inst):
	entities_in_range.append(Nonplayer_inst)


var is_player_autosauce: bool = false


func grapple_player(is_autosauce = false):
	if entities_in_range.empty(): return
		
	is_player_autosauce = is_autosauce

	var entity = entities_in_range[0]
	entity.hide_entity()
	entity.is_grappling_player = true
	mon_grappled_inst = entity
	should_fall_when_grappled = (entity.gravity_enabled) or entity.float_to_player

	
		
		
		
	if should_fall_when_grappled:
		for pos in get_tree().get_nodes_in_group("playerLastGroundedPosition"):
			self.global_position.y = pos.global_position.y
	else:
		self.global_position = entity.get_saucy_pos()

	emit_signal("player_grappled")
	
	mon_grappled_name = mon_grappled_inst.get_entity_name()
	_go_to_saucy_sprite(mon_grappled_name)


var is_boss: bool = false
func _start_grapple_mechanic():
	get_node("grappleSprites").show()
	_spawn_grapple_node()
	call_deferred("show_grapple_sprite")


func boss_grapple(boss_inst):
	is_boss = true
	should_fall_when_grappled = false
	emit_signal("set_grapple_state")
	emit_signal("player_grappled")
	call_deferred("show_grapple_sprite")
	

func _spawn_grapple_node():
	var grapple_inst = GRAPPLE_MECHANIC.instance()
	if is_boss:
		grapple_inst.mon_name = "boss"
		is_boss = false
	else:
		grapple_inst.entity_inst = mon_grappled_inst
	add_child(grapple_inst)
	
	player_sprite_anim.play("idle")
	























func _stop_saucy( var player_won: bool = false):
	entities_in_range = []
	if mon_grappled_inst != null and is_instance_valid(mon_grappled_inst):

		var mon_posi = mon_grappled_inst.global_position

		
		mon_posi.x = self.global_position.x
		mon_posi.y = self.global_position.y - 10 if mon_grappled_inst.is_stationary else mon_posi.y

		
		
		
		
		if mon_grappled_inst.get_entity_name() == "grabbed":
			mon_grappled_inst.saucy_finished()
		else:
			mon_grappled_inst.emit_signal("saucy_finished")
	
	
	

	should_fall_when_grappled = true
	being_saucied = false
	mon_grappled_inst = null
	show_saucy_sprite(false)
	set_decrease_stamina_rate(1)


func auto_saucy(body):
	enable_mox()
	is_auto_saucy = true
	_play_saucy_anim("wolf")
	show_saucy_sprite(true)
	mon_grappled_name = "wolf"



func show_grapple_sprite(show = true):
	match current_health:
		3: $grappleSprites / playerGrappleSprite / AnimationPlayer.play("clothed")
		2: $grappleSprites / playerGrappleSprite / AnimationPlayer.play("shirtless")
		1: $grappleSprites / playerGrappleSprite / AnimationPlayer.play("pantsless")
		0: $grappleSprites / playerGrappleSprite / AnimationPlayer.play("nude")

		_: $grappleSprites / playerGrappleSprite / AnimationPlayer.play("clothed")

	
	
	$grappleSprites / creatureGrappleSprite.visible = show

	var mon_dict = {
		"walnut": 1, 
		"hangmon": 2, 
		"shieldmon": 3, 
		"cordygreg": 4, 
		"flower": 5, 
		"tit_hugger": 6, 
		"ceiling_dweller": 7, 
		"umbrella": 8, 
		"koubold": 9, 
		"grabbed": 10, 
		"noodle": 11, 
		"wolf": 12, 
	}
	if mon_dict.has(mon_grappled_name):
		$grappleSprites / creatureGrappleSprite.frame = mon_dict[mon_grappled_name]
	else:
		$grappleSprites / creatureGrappleSprite.visible = false

	$grappleSprites / playerGrappleSprite.visible = show
	$playerSprite.visible = not show
	$grappleSprites / genericTenacle.visible = show if not mon_grappled_name in ["koubold", "wolf"] else false

	if mon_grappled_name == "koubold":
		is_woof_or_koubold = true
	else:
		is_woof_or_koubold = false

	if mon_grappled_name == "wolf":
		$grappleSprites / playerGrappleSprite.visible = false
		$grappleSprites / wolf.visible = show
		$grappleSprites / wolf.frame = clamp(3 - current_health, 0, 3)

		is_woof_or_koubold = true
	else:
		is_woof_or_koubold = false


	if mon_grappled_name == "":
		$grappleSprites / playerGrappleSprite.visible = false
		$grappleSprites / ScruffMoxTest.visible = show
	

func show_saucy_sprite(show):
	$saucySprite.visible = show
	$playerSprite.visible = not show
	$snowBreath.breath_active = not show

func stamina_depleted_breath():
	$snowBreath.emit_particles()











func _go_to_saucy_sprite(mon: String):
	saucy_sprite_anim.set_current_animation(mon)
	saucy_sprite_anim.seek(0, false)
	saucy_sprite_anim.stop(false)


func _play_saucy_anim(mon):
	Achievements.emit_signal("had_saucy", mon)
	saucy_sprite_anim.play(mon)
	if not who_saucied.has(mon) and not mon in ["koubold", "wolf"]:
		who_saucied.append(mon)
	_start_saucy_speed()




func tangle_anim():
	if Input.is_action_just_pressed("ui_left"): player_tangle_sprite.frame = 7
	if Input.is_action_just_pressed("ui_right"): player_tangle_sprite.frame = 6
	if Input.is_action_just_pressed("ui_space"): player_tangle_sprite.frame = 8


func _start_saucy_speed():
	saucy_speed_timer.start()
	saucy_speed_idx = 0


var saucy_speed_idx: int = 0
func _on_saucySpeedTimer_timeout():
	var speed_scales_list = [0.8, 1, 1.4]
	saucy_sprite_anim.playback_speed = speed_scales_list[saucy_speed_idx]
	saucy_speed_idx = clamp(saucy_speed_idx + 1, 0, speed_scales_list.size() - 1)

	if player_state == "saucied":
		saucy_speed_timer.start()
	else:
		saucy_speed_timer.stop()



var pump_timer = Timer.new()
var saucy_anim_done: bool = false
signal player_coomed
signal coom_ready

func start_pump_timer():
	pump_timer.set_one_shot(true)
	if not pump_timer.is_connected("timeout", self, "_pump_timer_timeout"):
		pump_timer.connect("timeout", self, "_pump_timer_timeout")
	pump_timer.start(3)


func _pump_timer_timeout():
	
	
	
	
	
	pass











onready var camera_anim_player = $playerCamera / cameraAnimationPlayer
var coom_capacity: int = 3
var continue_saucy: bool = true
var random = RandomNumberGenerator.new()

func _on_SaucyAnimationPlayer_animation_finished(_anim_name):
	var saucy_assigned_anim = saucy_sprite_anim.assigned_animation
	var length = len(saucy_assigned_anim)
	var last_four_letters = saucy_assigned_anim.right(length - 4)

	set_camera_bobbing(saucy_sprite_anim, mon_grappled_name)

	if not SettingsManager.is_bored_mode:
		decrease_stamina()
	else:
		add_stamina(10)

	if continue_saucy:
		saucy_sprite_anim.play(mon_grappled_name)
		random.randomize()
		var chance = random.randi_range(0, 99)
		if ( not mon_grappled_name in ["shieldmon", "cordygreg", "flower"]) and \
		chance <= 20:
			$Audio.play_voice()

	elif last_four_letters != "_cum":
		var coom_variant = mon_grappled_name + "_cum"
		saucy_sprite_anim.play(coom_variant)
		if player_ui.stamina_just_reached_zero:
			spawn_coom()
			_add_coom_count(1)
	else:
		continue_saucy = true
		saucy_anim_done = true
		stop_cum_vignette()

	check_if_woof_or_koubold(mon_grappled_name)


func check_if_woof_or_koubold(name):
	if name in ["wolf", "koubold"]:
		is_woof_or_koubold = true


func _is_saucy_animation_done() -> bool:
	if saucy_anim_done:
		saucy_anim_done = false
		return true
	return false



func set_camera_bobbing(saucy_sprite_anim, creature):
	
	
	
	
	
	var posi = Vector2(0, 2)
	match creature:
				"walnut": posi = Vector2(2, - 2)
				"hangmon": posi = Vector2( - 2, 2)
				"flower": posi = Vector2(0, 6)
				"cordygreg": posi = Vector2(0, 4)
				"noodle": posi = Vector2(0, - 2)

	
	AnimationManager.add_keyframe(saucy_sprite_anim, creature, "../playerCamera:offset", 
										saucy_sprite_anim.current_animation_length / 2.0, 
										posi, 0.5)
	
	AnimationManager.add_keyframe(saucy_sprite_anim, creature, "../playerCamera:offset", 
										0, Vector2(0, 0), 2.0)
	
	AnimationManager.add_keyframe(saucy_sprite_anim, creature, "../playerCamera:offset", 
										saucy_sprite_anim.current_animation_length, 
										Vector2(0, 0), 1.0)



func turn_continue_saucy_false():
	print_debug(self.get_name(), ": pressed coom button")
	emit_signal("player_coomed")
	is_saucied_with_koubold = false
	is_auto_saucy = false
	continue_saucy = false



func start_cum_vignette():
	$UI / playerCumVignette / cumVignetteVisible.play("Show")
	$UI / playerCumVignette / cumVignettePlayer.play("stronger_vignette_fade")


func stop_cum_vignette():
	$UI / playerCumVignette / cumVignetteVisible.play_backwards("Show")
	


func spawn_coom():
	var pos = $coomPosition
	var something = load("res://Src/Entities/Player/z_test_scenes/coom.tscn")
	var instance = something.instance()
	instance.position = pos.position
	add_child(instance)



func _add_coom_count( var count):
	
	
	coom_count += count
	update_coom_circles()

func _clear_coom_count( var count = null):
	if count == null:
		coom_count = 0
	else:
		var new_coom_count = coom_count - count
		coom_count = clamp(new_coom_count, 0, 3)
	update_coom_circles()




func update_coom_circles():
	
	$UI / Circles.visible = (coom_count > 0)
	for circle in $UI / Circles.get_children():
		circle.hide()

	if coom_count > 0:
		$UI / Circles / circle_border_filled.show()
		if coom_count > 1:
			$UI / Circles / circle_border_filled2.show()
			if coom_count > 2:
				$UI / Circles / circle_border_filled3.show()




func can_be_saucied( var states_that_can_be_saucied = []) -> bool:
	
	
	

	if not disable_saucy_timer.is_stopped(): return false

	for state in states_that_can_be_saucied:
		if state == player_state:
			return true

	if player_state == "jump" or player_state == "fall": return false
	
	if mon_grappled_inst == null:
		return true

	return false


func disable_mox():
	
	emit_signal("set_state", "disabled")
	is_player_input_disabled = true


func disable_input():
	is_player_input_disabled = true


func enable_mox():
	
	emit_signal("set_state", "idle")
	is_player_input_disabled = false


func is_disabled() -> bool:
	return player_state == "disabled"
	

export (Resource) var afterglow_up_arrow

var is_afterglow: bool = false
func start_afterglow():
	is_afterglow = true
	disable_saucy_timer.start(10)
	$UI.add_child(afterglow_up_arrow.instance())


func start_custom_afterglow():
	print("timeout")
	if current_health > 0:
		current_health -= 1
	else:
		coom_count = coom_capacity
		start_afterglow()
	player_clothes()


var is_woof_or_koubold: bool = false
var can_go_to_chamber: bool = false




















func start_next_level_fade_transition():
	ScreenManager.set_fade_timeout_signal(self, "transition_to_afterglow")
	ScreenManager.fade(0.6, 1.4)


func transition_to_afterglow():
	
	PosManager.pass_scene_properties(PosManager.curr_start_pos, get_owner())

	if is_woof_or_koubold:
		is_woof_or_koubold = false
		_clear_coom_count()
		SceneChanger._change_scene("res://Src/1_World/1_zones/ship/Stage-SaveStation.tscn", 0.5, 1)

	elif not can_go_to_chamber:
		coom_count = 0
		_clear_coom_count()
		SceneChanger._change_scene(PosManager.previous_level, 0.1, 1)

	else:
		SceneChanger._change_scene("res://Src/1_World/1_zones/GalleryRoom/Stage_01-GalleryRoom.tscn", 0.1, 1)

	Globals.set_global_player_variables(save_to_globals())
	can_go_to_chamber = false
	
	




var is_seated: bool = false

func set_state( var starting_state):
	match starting_state:
		"idle": return
		"sit": sit()

func sit():
	is_seated = true








func _check_if_player_grappled( var _mon_type = null) -> bool:
	return true if mon_grappled_inst != null else false

func _return_to_idle(): return_to_idle = true








const SLOPE_STOP: float = 1.0472

var velocity = Vector2()
var move_speed: int = 0
var gravity = 18 * 100
var jump_velocity = - 720
var double_jump_count = 2
var snap = Vector2(0, 0)
var jumped: bool = false
var can_jump: bool = false

onready var coyote_timer = $coyoteTimer
onready var jump_buffer = $jumpBuffer

func _apply_movement():
	
	
	
	
	
	velocity.y = move_and_slide_with_snap(velocity, snap, Vector2.UP, true).y
	

	
	

	
	if is_on_floor():
		coyote_timer.start(0.2)
		jumped = false

	
	if is_on_floor() and not jump_buffer.is_stopped() and can_jump:
		jump_buffer.stop()
		jump_stamina_penalty()
		jump()

	
	


func snap_to_floor():
	self.snap = Vector2.DOWN * 100
									



func disable_snap_to_floor():
	self.snap = Vector2(0, 0)


func _apply_gravity(delta):
	velocity.y += gravity * delta


var should_move: bool = false


onready var foot_edge_raycast = $detectArea / footEdgeDetectRaycast
onready var knee_wall_raycast = $detectArea / kneeWallDetectRaycast

var one_handed_movement: int = 0 setget set_one_handed_movement
signal stamina_empty_jump

func _handle_move_input():
	var move_direction: int
	var left_or_right = Input.is_action_pressed("kb_left") or Input.is_action_pressed("kb_right")\
	or Input.is_action_pressed("joy_left") or Input.is_action_pressed("joy_right")

	if left_or_right:
		move_direction = - int(Input.is_action_pressed("kb_left") or Input.is_action_pressed("joy_left"))\
		+ int(Input.is_action_pressed("kb_right") or Input.is_action_pressed("joy_right"))

	elif one_handed_movement:
		move_direction = one_handed_movement

	
	
	
	else:
		move_direction = 0

	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())

	if is_on_floor() and is_on_wall()\
	and foot_edge_raycast.is_colliding()\
	and not knee_wall_raycast.is_colliding():
		step_up_ledge()
	
	
	if (Input.is_action_just_pressed("ui_up")\
	or Input.is_action_just_released("ui_scroll_up")\
	or Input.is_action_just_pressed("ui_jump")) and not is_disabled():
		if (is_on_floor() or not $coyoteTimer.is_stopped() and not jumped) and can_jump:
			coyote_timer.stop()
			jump_stamina_penalty()
			jump()
		elif not can_jump:
			emit_signal("stamina_empty_jump")

		else:
			jump_buffer.start(jump_buffer_time)


func _get_h_weight():
	return 0.2 if is_on_floor() else 0.1


func jump_stamina_penalty():
	if not SettingsManager.is_jump_stamina_drain_mode or SettingsManager.is_bored_mode: return
	stamina -= jump_stamina_penalty



func set_can_jump():
	if stamina < 5:
		can_jump = false
	elif stamina > 20:
		can_jump = true


func jump(given_height = 0):
	jumped = true
	disable_snap_to_floor()
	velocity.y = jump_height if given_height == 0 else given_height


func step_up_ledge():
	jump( - 350)



func _lower_jump( var jump): jump_height = jump


func _default_jump(): jump_height = max_jump_height


func _reset_jump_height_timer( var time: float = 0.2):
	reset_jump_height_timer.start(time)



func _on_reset_jump_height_timeout(): _default_jump()


func _movement_slow_speed( var speed: int = 0): move_speed = speed


func _set_movement_speed( var speed: int = 0): move_speed = speed


func _movement_default_speed(): move_speed = max_speed



func set_max_speed(value):
	move_speed = value
	max_speed = value







signal player_tenta_grapple

func _on_free_grapple( var player_won = true, var can_decrease_stamina: = true):
	call_deferred("knock_back_surrounding_Nonplayer")
	flashlight_visibility()
	if not player_won and not SettingsManager.is_bored_mode and can_decrease_stamina:
		decrease_stamina(40)
	elif SettingsManager.is_bored_mode:
		add_stamina(30)

	global_position.y -= 20
	_stop_saucy(player_won)
	set_decrease_stamina_rate(1)
	
	emit_signal("set_idle_state")
	emit_signal("player_grapple_freed")

	if not player_won:
		emit_signal("player_tenta_grapple")



func _on_grapple_to_saucy():
	if SettingsManager.is_bored_mode:
		add_stamina(30)
	else:
		decrease_stamina(50)

	if mon_grappled_inst != null:
		_play_saucy_anim(mon_grappled_name)
	else:
		print_debug("Player: is null. Returning to idle")


func knock_back_surrounding_Nonplayer():
	for body in knock_back_range.get_overlapping_bodies():
		if body.get_class() == "Nonplayer":
			body.stun(global_position)


func _on_Node2D_new_time(day):
	if curr_day_or_night == day: return

	curr_day_or_night = day
	day_or_night = day
	nightTimeVignette()
	night_torch()

func get_lighting_condition():
	return day_or_night


func tape_found():
	emit_signal("tape_found")












func set_one_handed_movement(value):
	one_handed_movement = value









onready var audio = $Audio
onready var voice = $Audio / voice
var floor_type: String = "dry"

signal floor_type_changed


func _set_floor_type(type):
	floor_type = type
	emit_signal("floor_type_changed")


func connect_to_audio_script():
	connect("floor_type_changed", $Audio, "_set_audio_floor_type")


func _land_sound():
	$Audio / land.play()






var is_one_handed_reminded: bool = false

func save_to_globals():
	var save = {
		"current_health": current_health, 
		"ammo_count": ammo_count, 
		"stamina": stamina, 
		"magazine_arr": magazine_arr, 
		"flashlight_active": flashlight_active, 
		"coom_count": coom_count, 
		"show_debug": show_debug, 
		"should_move": should_move, 
		"dir": dir, 
		"who_saucied": who_saucied, 
		"is_blaster_enabled": is_blaster_enabled, 
		"is_most_ammo_first": is_most_ammo_first, 
		"is_one_handed_reminded": is_one_handed_reminded, 
	}
	return save


func save_to_file():
	var save = {
		"current_health": current_health, 
		"ammo_count": ammo_count, 
		"magazine_arr": magazine_arr, 
		"is_blaster_enabled": true, 
		"is_most_ammo_first": is_most_ammo_first, 
		"is_one_handed_reminded": is_one_handed_reminded, 
	}
	return save


func _on_playerStuckTimer_timeout():
	player_ui.show_player_stuck_label()
