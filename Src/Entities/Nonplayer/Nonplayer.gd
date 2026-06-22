class_name Nonplayer
extends Entity


export (String) var entity_name = ""
export (bool) var is_asleep = false setget set_is_asleep
export (int) var max_health = 1
export (int) var MAX_SPEED = 300
export (int) var jump_height = - 300

export (int) var acceleration = 50
export (float) var can_saucy_time = 0.1
export (float) var afterglow_time = 0
export (float) var stun_time = 2
export (bool) var gravity_enabled = true
export (bool) var float_to_player = false
export (bool) var can_be_stunned = true
export (bool) var is_stationary = false
export (bool) var allow_knock_back = true
export (bool) var is_disabled = false
export (bool) var can_chase_player_on_first_sight = true
export (Array) var player_states_i_can_saucy = []
export (bool) var show_debug = false

onready var enterDetect = get_node("detectBodies/enterDetect")
onready var exitDetect = get_node("detectBodies/exitDetect")
onready var attack_range = get_node("detectBodies/attackRange")
onready var stun_timer = $stunTimer
onready var can_saucy_timer = get_node("canSaucy")
onready var check_attack_bodies_timer = $checkAttackBodiesTimer

var current_health: int = 1
var can_saucy: bool = true
var stunned: bool = false
var afterglow: bool = false
var _func_ready_take_damage: int = 0
var is_player_near_chasing_range: bool = false
var allow_hit_sound: bool = true
var should_sauce_mox: bool = false


var is_alive = true
var attack_body
var friction = false
var movement








func _generic_ready():
	if not is_alive:
		queue_free()

	set_debug_visibility()

	current_health = max_health
	current_health -= _func_ready_take_damage
	move_speed = MAX_SPEED
	
	movement = true
	setDir("left")

	connect("saucy_finished", self, "saucy_finished")
	connect("saucy_started", self, "saucy_started")
	Globals.connect("debug_mode_set", self, "set_debug_visibility")

	exploration_mode_changed()


func disable_creature():
	pass


func is_alive():
	if not is_alive:
		call_deferred("free")





func get_entity_name():
	return entity_name.substr(2, - 1)
	

func get_class(): return "Nonplayer"


func get_saucy_pos():
	return $playerSaucyPos.global_position




func _on_exitDetect_body_exited(_body):
	movement = true



func _on_sightLine_body_entered(body):
	if body.get_name() == "playerChar":
		seen_player = true
		player = body


func _on_sightLine_body_exited(body):
	if body.get_name() == "playerChar":
		seen_player = false
		if not force_chase:
			player = null


func _on_chaseSightLine_body_entered(body):
	if body.get_name() == "playerChar":
		is_player_near_chasing_range = true
		if can_chase_player_on_first_sight:
			set_destination(body)


func _on_chaseSightLine_body_exited(body):
	if body.get_name() == "playerChar":
		is_player_near_chasing_range = false
		if target_destination == body:
			set_destination(null)

func _on_sleepTimer_timeout():
	is_asleep = false
	$sleepyParticles.emitting = false


func check_if_player_in_chase_range():
	for p in get_node("chaseSightLine").get_overlapping_bodies():
		if Globals._is_player(p) and not SettingsManager.is_exploration_mode:
			player = p


func _on_attackRange_body_entered(body):
	check_if_player_in_attack_body(body)


func _on_attackRange_body_exited(_body):
	attack_body = null


signal plant_cleared

func _on_deathAnimationPlayer_animation_finished(_anim_name):
	is_alive = false
	EntityManager.call_deferred("save_entity", save())
	self.connect("plant_cleared", Achievements, "plant_cleared")
	emit_signal("plant_cleared")
	call_deferred("free")



func hide_entity():
	self.hide()
	_creature_sounds("stop_all")



func show_Nonplayer():
	self.show()

	if not SettingsManager.is_exploration_mode:
		_creature_sounds("skitter")
		_creature_sounds("screech")


func check_if_player_in_attack_body(body = null, autowin = false, is_autosauce = false):
	if body == null:
		if attack_range.monitoring:
			for b in attack_range.get_overlapping_bodies():
				if Globals._is_player(b) and not SettingsManager.is_exploration_mode:
					saucy(b)
				elif is_autosauce:
					saucy(b, true)

	elif isEnemy(body):
		if not SettingsManager.is_exploration_mode:
			saucy(body)
		elif is_autosauce:
			saucy(body, true)


func set_is_asleep(value):
	is_asleep = value
	$sleepyParticles.emitting = is_asleep






func saucy(player, is_autosauce: bool = false):
	if player.can_be_saucied(player_states_i_can_saucy) and not is_asleep:
		player.fall_in_line(self)
		player.call_deferred("grapple_player", is_autosauce)
	else:
		self_saucy = true










var new_dir: String
func _check_attackRange_when_creature_turn():
	if dir != new_dir:
		check_if_player_in_attack_body()
		new_dir = dir


func _check_if_player_in_range():
	if check_attack_bodies_timer.is_stopped():
		check_if_player_in_attack_body()
		check_attack_bodies_timer.start()


func _creature_sounds( var state):
	if has_node("/Audio"):
		match state:
			"screech": $Audio / skitter.play()
			"skitter": $Audio / screech.play()
			"fire": $Audio / fire.play()
			"stop_all":
				for audio in $Audio.get_children():
					audio.stop()














var force_chase: bool = false
var force_chase_source: String
var seen_player: bool = false
var is_grappling_player: bool = false
var self_saucy: bool = false


func force_chase( var boolean, var source_name = ""):
	force_chase = boolean
	player = Globals.get_player() if force_chase else null
	force_chase_source = source_name if force_chase else ""

	set_destination(player)


func _can_chase() -> bool:
	if SettingsManager.is_exploration_mode: return false
	if _is_shot_at(): return true
	if force_chase: return true
	if should_move_to_destination: return true
	if target_destination == null or not is_player_near_chasing_range: return false
	if is_afterglow(): return false
	return true


func stop_force_chase():
	pass



func _should_stop_chase() -> bool:
	return true if ((target_destination == null or is_afterglow() or is_asleep) and not force_chase) else false


func is_afterglow() -> bool:
	return Globals.get_player().is_afterglow


func _can_afterglow() -> bool:
	return true if afterglow else false


func _should_return_to_idle():
	var player_char = Globals.get_player()
	return true if player_char.mon_grappled_inst == null else false

	


func _should_self_saucy() -> bool:
	return true if self_saucy else false


func _should_stun() -> bool:
	return true if stunned else false


func _should_return_stun_to_idle():
	return true if (stun_timer.is_stopped() and stunned) else false


func stun(global_pos):
	if allow_knock_back:
		knock_back(1000, global_pos)

	if can_be_stunned:
		set_stunned(true)
		set_can_saucy(true)
		stun_timer.start(stun_time)


func sleep():
	is_asleep = true
	$sleepTimer.start()
	$sleepyParticles.emitting = true


func set_can_saucy(boolean):
	can_saucy = boolean


func set_stunned(boolean):
	stunned = boolean


func _is_afterglow_timer_finished() -> bool:
	return $afterglowTimer.is_stopped()


func _start_afterglow_timer( var time = afterglow_time):
	get_node("afterglowTimer").start(time)
	

	



func _is_shot_at() -> bool:
	if current_health != max_health:
		is_asleep = false
		force_chase(true, "Player shot me. Ow :(. Chasing player now.")
		return true
	return false





const SLOPE_STOP = 64




var player = null
var target_destination = null

var velocity = Vector2()
var move_speed: float
var gravity = 18 * 100
var jump_velocity = - 720
var move_direction = 0

var should_move_to_destination: bool = false















func _apply_movement():
	if float_to_player:
		_float_to_player()
	else: velocity.y = move_and_slide(velocity, UP, SLOPE_STOP).y

export (bool) var slow_down_near_target = false

func _handle_movement():
	
	if target_destination != null:
		if is_close_to_destination(self.global_position, target_destination.global_position) and slow_down_near_target:
			velocity.x = lerp(velocity.x, 0, _get_h_weight())
			return
	_handle_horizontal_movement()


func _handle_horizontal_movement():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())


func _float_to_player():
	var motion
	var movedir: Vector2

	if player == null and not seen_player:
		motion = Vector2(0, 0)
	else:
		movedir = player.global_position - global_position
		motion = movedir.normalized() * move_speed
	
	move_and_slide(motion, Vector2(0, 0))


func _apply_gravity(delta):
	if float_to_player: return
	velocity.y += gravity * delta if gravity_enabled else 0


func _get_h_weight():
	return 0.2 if is_on_floor() else 0.1



func jump():
	velocity.y = jump_height


func _movement_slow_speed( var speed: int = 0):
	move_speed = speed


func _movement_default_speed():
	move_speed = MAX_SPEED






func modify_default_speed():
	move_speed = MAX_SPEED
	move_speed -= randi() % 30 + 1


func is_close_to_destination(vec2_a, vec2_b) -> bool:
	return true if vec2_a.distance_to(vec2_b) < 80 else false





func set_destination(body):
	target_destination = body


func go_to_destination(body):
	set_destination(body)
	should_move_to_destination = true



func at_destination():
	should_move_to_destination = false




func _chase_player():
	_set_dir_to_destination()


func _set_dir_to_destination():
	if target_destination != null:
		dir = "right" if target_destination.global_position.x > global_position.x else "left"




func _Nonplayer_direction( var active: bool = false):
	if active:
		match dir:
			"left": move_direction = - 1
			"right": move_direction = 1
	else: move_direction = 0






signal saucy_started
signal saucy_finished

func saucy_started():
	print("saucy started")


func saucy_finished():
	show_Nonplayer()
	is_grappling_player = false



func hpStat( var int_modi: int, var modifier: String):
	match modifier:
		"heal": current_health += int_modi
		"dmg": current_health -= int_modi


func take_damage( var dmg: int, var posi = Vector2(), var knock_back_force = 100):
	hpStat(dmg, "dmg")
	if allow_knock_back:
		knock_back(knock_back_force, posi)
	is_asleep = false
	$hit.play("hit_indication")
	if allow_hit_sound:
		SoundManager.play_smart_audio("enemy_hit", 0)


func isEnemy( var body):
	return body.get_name() == "playerChar"


func canDie():
	if not 0 >= current_health: return

	is_alive = false
	
	$deathSprite.show()
	$deathSprite / AnimationPlayer.play("dead")
	$normSprite.hide()

	$detectSelf / CollisionShape2D.disabled = true
	_disable_detect_range()
	
	movement = false


func _on_attackSprite_animation_finished():
	pass



func _disable_detect_range():
	$detectBodies / enterDetect / collisionShape.disabled = false
	$detectBodies / attackRange / CollisionShape2D.disabled = true

func _set_detect_range(boolean = null):
	
	
	

	var enter = $detectBodies / enterDetect / collisionShape
	var attack = $detectBodies / attackRange / CollisionShape2D

	enter.disabled = not enter.disabled if boolean == null else not boolean
	attack.disabled = not attack.disabled if boolean == null else not boolean




func knock_back( var force: int, var dir):
	if not allow_knock_back: return

	if typeof(dir) == TYPE_STRING:
		if dir == "left":
			velocity.x = - force
		elif dir == "right":
			velocity.x = force
	
	elif typeof(dir) == TYPE_VECTOR2:
		
		
		
		if global_position.x < dir.x:
			velocity.x = - force
		elif dir.x < global_position.x:
			velocity.x = force
		





func save():
	var save_dict = {
		"unique_id": get_name(), 
		"parent_path": get_parent().get_path(), 

		
		
		"owner_path": get_owner().get_filename(), 
		"is_alive": is_alive, 
	}
	return save_dict





var flashed: bool = false
func flashed(boolean):
	
		
	
	pass

func flashed_by_flashlight():
	
		
	
	
	

	
	pass

func not_flashed_anymore():
	

	
	
	
	
	pass

func alert_other_creatures():
	
		
			
	pass

func alerted():
	pass


func set_debug_visibility():
	
	$state.hide()


func exploration_mode_changed():
	if SettingsManager.is_exploration_mode:
		player = null
		add_to_group("Interactable")
	else:
		check_if_player_in_chase_range()
		

func _on_enterDetect_body_entered(body: Node):
	if Globals._is_player(body) and SettingsManager.is_exploration_mode:
		$Hand / AnimationPlayer.play("wave")


func _player_entered():
	if SettingsManager.is_exploration_mode:
		$Arrow.show()
	else:
		$Arrow.hide()



func _player_exited():
	$Arrow.hide()


func interacted():
	if self.entity_name == "f_grabbed" and SettingsManager.is_exploration_mode:
		$Hand / AnimationPlayer.play("wave")
		return

	check_if_player_in_attack_body(null, false, true)


