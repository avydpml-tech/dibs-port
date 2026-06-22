extends Nonplayer











export (String, "idle", "disabled", "angry", "door_idle") var starting_state = "idle"
export (bool) var is_in_mall = false
export (bool) var can_allow_interact = false
export (float) var time_before_walk = 6
export (NodePath) var walk_end_point = null
export (int) var walking_speed = 300
export (bool) var ignore_mox = true
export (bool) var should_start_time_before_walk = false
export (int) var hit_max_tolerance = 5
export (bool) var is_debug_print = false


onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite

var enemy_state = "idle"
var hit_tolerance: int = 0

signal wolf_walk_finished

func _ready():
	_generic_ready()
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()

	get_node("lightVignette").show()

	
	if walk_end_point != null:
		target_destination = get_node(walk_end_point)
	else:
		target_destination = null

	
	if Achievements.is_woof_encountered:
		if target_destination != null:
			self.global_position = target_destination.global_position
		is_door_opened = true
		starting_state = "idle"

	
	if starting_state == "door_idle":
		norm_sprite.hide()
		$Door.show()
		$snowBreath.breath_active = false
	
	if is_in_mall and not Achievements.is_allow_wolf_in_mall:
		call_deferred("free")
	
	Globals.connect("woof_jazz_played", self, "jazz_played")
	Globals.connect("walk_area_entered", self, "_stop_hug")

	if not Globals.get_player().is_connected("player_coomed", self, "_spawn_tape"):
		if Globals.get_player().connect("player_coomed", self, "_spawn_tape") != OK:
			print(self, ": player_coomed signal not connecting to _spawn_tape()")

	if can_allow_interact:
		add_to_group("Interactable")
	
	if is_in_mall:
		jazz_played()
	
	if should_start_time_before_walk and Achievements.is_woof_encountered:
		$timeBeforeWalk.start(time_before_walk)

	$Hand.hide()


func disable_interact():
	if is_in_group("Interactable"):
		remove_from_group("Interactable")


var is_grappled: bool = false
func _process(_delta):
	animate_sprite()
	if not is_in_mall:
		if Achievements.is_allow_wolf_in_mall:
			call_deferred("free")

	
	
	
	if not Achievements.is_woof_and_koubold_encountered:
		if Globals.get_player().player_state in ["saucied", "grappled"]:
			hide()
			is_grappled = true
		else:
			if is_grappled:
				show()
	
	if is_hug and SettingsManager.is_bored_mode:
		Globals.add_stamina(3)


func jazz_played():
	if Globals.is_woof_jazz:
		get_node("jazz").play()
		SoundManager.set_music_effect("none")
	elif not Globals.is_woof_jazz:
		$jazz.stop()


func _input(event):
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_stop_hug()









func flashed_by_flashlight():
	if flashed: return
	player = Globals.get_player()
	flashed = true
	if is_debug_print:
		print_debug(Globals.new_timestamp(), self.get_name(), " got flashed")


func not_flashed_anymore():
	if not flashed: return
	if is_debug_print:
		print_debug(Globals.new_timestamp(), self.get_name(), ": not flashed anymore")
	flashed = false


func flashed(boolean):
	flashed = boolean


func _on_flashedTimer_timeout():
	if not flashed:
		call_deferred("check_if_player_in_attack_body")





func _on_calmDownTimer_timeout():
	hit_tolerance = 0


func return_to_idle():
	should_return_to_idle = true


var should_return_to_idle: bool = false
func _should_return_to_idle() -> bool:
	var temp_should_return_idle = should_return_to_idle
	should_return_to_idle = false
	return true if temp_should_return_idle else false


func _is_shot_at() -> bool:
	if hit_tolerance > 0:
		print_debug(Globals.new_timestamp(), self, ": hit_tolerance more than 0. Staying annoyed.")
		return true
	return false




func _on_headTurnArea_area_entered(area: Area2D):
	if area.get_name() == "wolfEndPoint" and enemy_state != "angry":
		is_near_end_point = true
		should_walk = false
		emit_signal("wolf_walk_finished")


func _on_headTurnArea_body_exited(body: Node):
	if Globals._is_player(body):
		if body.global_position > self.global_position:
			should_head_turn = true
		elif body.global_position < self.global_position:
			should_return_head_turn = true
	


var should_head_turn: bool = false
func should_head_turn() -> bool:
	var temp_should_head_turn = should_head_turn
	should_head_turn = false
	return true if temp_should_head_turn else false


var should_return_head_turn: bool = false
func should_return_head() -> bool:
	var temp_should_head_turn = should_return_head_turn
	should_return_head_turn = false
	return true if temp_should_head_turn else false


func set_back_destination():
	if walk_end_point != null:
		target_destination = get_node(walk_end_point)
	else:
		target_destination = null

var is_door_opened: bool = false



func door_opened():
	jazz_played()
	is_door_opened = true

var is_near_end_point: bool = false
var should_walk: bool = false
var just_door_idle: bool = false

func _on_timeBeforeWalk_timeout():
	should_walk = true



func _set_walking_speed(input = null):
	move_speed = walking_speed if input == null else input


func _set_running_speed():
	move_speed = MAX_SPEED


func start_walk_timer():
	$timeBeforeWalk.start(time_before_walk)


func is_in_walk_end_point() -> bool:
	var end_point_node_name = walk_end_point.get_name(walk_end_point.get_name_count() - 1)

	for detectSelf in $detectSelf.get_overlapping_areas():
		if detectSelf.get_name() == end_point_node_name:
			just_door_idle = false
			return true
	return false


func flip_wolf_sprite(state):
	if state in ["idle"]:
		$normSprite.flip_h = false
	elif state in ["walk"]:
		if target_destination.global_position < global_position:
			$normSprite.flip_h = false
		else:
			$normSprite.flip_h = true
	




func take_damage( var dmg: int, 
					var posi = Vector2(), 
					var knock_back_force = 100, 
					volume = - 5):
	hit_tolerance += 1
	$calmDownTimer.start()
	$hit.play("hit_indication")
	SoundManager.play_smart_audio("unsatisfying_hit", volume)


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()


func _on_doorOpenArea_body_entered(body):
	if Globals._is_player(body)\
	and starting_state == "door_idle"\
	and not is_door_opened:
		var norm_sprite_anim_tree = get_node("normSprite/AnimationTree").get("parameters/playback")
		$Door.hide()
		norm_sprite.show()
		norm_sprite_anim_tree.call_deferred("travel", "door_open")
		Achievements.is_woof_encountered = true
		$timeBeforeWalk.start(time_before_walk)
		get_node("snowBreath").breath_active = true






func saucy(player, is_autosauce: bool = false):
	if ignore_mox: return
	if player.can_be_saucied(player_states_i_can_saucy):
		player.fall_in_line(self)
		player.call_deferred("grapple_player")
	else:
		self_saucy = true


func saucy_finished():
	show_Nonplayer()
	is_grappling_player = false
	should_return_to_idle = true



func check_if_player_in_attack_body(body = null, autowin = false, is_autosauce = false):
	if body == null:
		if attack_range.monitoring:
			for b in attack_range.get_overlapping_bodies():
				if Globals._is_player(b):
					saucy(b)
				elif is_autosauce:
					saucy(b, true)

	elif isEnemy(body):
		if true:
			saucy(body)
		elif is_autosauce:
			saucy(body, true)





func animate_sprite():
	
	
	pass

func _on_hit_animation_finished(_anim_name):
	modulate = "ffffff"


func _creature_sounds( var state):
	match state:
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()
		_: pass


func saucy_mox():
	Globals.get_player().auto_saucy(self)
	ScreenManager.fade(0.05, 0.3)
	_stop_hug()
	hide()

func _on_sightLine_body_entered(body):
	if body.get_name() == "playerChar":
		seen_player = true
		player = body
		
		if is_in_mall and Achievements.is_woof_encountered:
			Achievements.is_seen_woof_by_window = true






onready var norm_sprite_anim_tree = get_node("normSprite/AnimationTree").get("parameters/playback")

var is_hug: bool = false

func _start_hug():
	if not is_hug:
		ScreenManager.fade(0.04, 0.3, 0.1)

	is_hug = true

	match (Globals.get_player().current_health):
		
		3:
			norm_sprite_anim_tree.travel("hug_arm_down")
			norm_sprite_anim_tree.travel("hug_arm_down")
		2: norm_sprite_anim_tree.travel("hug_bra")
		1:
			norm_sprite_anim_tree.travel("hug_2")
			Achievements.is_saucied_woof = true
		0:
			if not Achievements.is_woof_saucied:
				norm_sprite_anim_tree.travel("hug_nude")
				Achievements.is_woof_saucied = true
				Achievements.is_saucied_woof = true
			else:
				norm_sprite_anim_tree.travel("hug_nude_after_sauce")

	
	Globals.get_player().position.x = self.position.x
	Globals.get_player().dir = "left"
	Globals.get_player().call_deferred("disable_mox")

	$Arrow.hide()

func _stop_hug():
	if not is_hug:
		return
	Globals.get_player().enable_mox()
	norm_sprite_anim_tree.travel("idle")
	$brokeLabel.hide()
	$noAnim.hide()
	is_hug = false

func _on_enterDetect_body_entered(body: Node):
	pass



var player_entered: bool = false
func interacted():
	if Globals.get_player().player_state in ["sit", "jump", "fall"]:
		return
	
	if not Achievements.is_allow_wolf_in_mall and \
	not Achievements.is_woof_and_koubold_encountered:
		return

	if not is_hug and not enemy_state in ["walk"]:
		_start_hug()



func item_activated():
	pass

func _player_entered():
	if not Achievements.is_allow_wolf_in_mall: return
	_show_silhouette()
	player_entered = true
	
func _player_exited():
	if not Achievements.is_allow_wolf_in_mall: return
	_hide_silhouette()
	player_entered = false
	

func _show_silhouette():
	$Arrow.show()
	
func _hide_silhouette():
	$Arrow.hide()

func _spawn_tape():
	for tape in get_tree().get_nodes_in_group("Tape"):
		if tape.tape_name == "woof1":
			tape.enable()

func _on_exitDetect_area_exited(area: Area2D):
	if area.get_name() == "wolfEndPoint":
		is_near_end_point = false
