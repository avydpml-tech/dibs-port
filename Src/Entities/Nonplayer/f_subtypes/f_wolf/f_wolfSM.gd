extends NonplayerStateMachine




func _ready():
	_generic_ready()
	add_state("open_door")
	add_state("walk")
	add_state("flashed")
	add_state("annoyed")
	add_state("angry")
	add_state("pounce")
	add_state("hug")
	add_state("calm_down")
	add_state("door_idle")
	add_state("head_turn")

	
	

	if parent.is_disabled:
		call_deferred("set_state", states.disabled)
	else:
		match (parent.starting_state):
			"disabled": call_deferred("set_state", states.disabled)
			"idle": call_deferred("set_state", states.idle)
			"angry": call_deferred("set_state", states.angry)
			"door_idle": call_deferred("set_state", states.door_idle)


func _state_logic(delta):
	fiddle_parent_state()
	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	parent._handle_movement()
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow, states.calm_down, states.annoyed, states.head_turn].has(state):
		parent._Nonplayer_direction(false)
		parent._set_walking_speed(0)
		
	elif state == states.walk:
		parent._chase_player()
		parent._set_walking_speed()
		parent._should_jump()
		parent._Nonplayer_direction(true)

	elif state == states.angry:
		parent._chase_player()
		parent._set_running_speed()
		parent._should_jump()
		parent._Nonplayer_direction(true)
		parent._check_attackRange_when_creature_turn()
	
	elif state == states.self_saucy:
		parent._Nonplayer_direction(false)


func _get_transition(_delta):
	match state:
		states.idle:
			if parent.is_disabled: return states.disabled
			if parent.flashed: return states.flashed
			if parent._is_shot_at(): return states.annoyed
			if parent.should_walk and not parent.is_near_end_point: return states.walk
			if parent.should_head_turn(): return states.head_turn
			if parent._can_afterglow(): return states.afterglow
			if parent.is_hug: return states.hug


		states.flashed:
			if parent._is_shot_at(): return states.annoyed
			if not parent.flashed: return states.idle
			if parent.is_hug: return states.hug
			if parent.should_walk and not parent.is_near_end_point: return states.walk
			if parent.should_head_turn(): return states.head_turn
		
		states.hug:
			if not parent.is_hug: return states.idle
				

		states.annoyed:
			if parent.hit_tolerance == 0: return states.calm_down
			if parent.hit_tolerance == parent.hit_max_tolerance: return states.angry
		
		states.calm_down:
			
			
			
			
			if parent._should_return_to_idle(): return states.idle
		
		states.angry:
			
			
				
			if parent._should_stun(): return states.stunned
			if parent._should_return_to_idle(): return states.calm_down
			pass

		states.stunned:
			if parent._should_return_stun_to_idle():
				return states.calm_down

		states.chase:
			
			
			
			
			pass

		states.afterglow:
			if parent._is_afterglow_timer_finished():
				return states.idle
			if parent._should_stun(): return states.stunned
		
		states.self_saucy:
			pass

		states.door_idle:
			if parent.is_door_opened:
				return states.idle

		states.walk:
			if parent._is_shot_at(): return states.annoyed
			if parent.is_near_end_point:
				return states.idle

		states.head_turn:
			if parent.flashed: return states.flashed
			if true: return states.idle
			

	return null


func _enter_state(new_state, old_state):
	var norm_sprite_anim_tree = parent.get_node("normSprite/AnimationTree").get("parameters/playback")

	match new_state:
		states.attack: pass
		states.walk:
			parent.flip_wolf_sprite("walk")
			norm_sprite_anim_tree.travel("walk")
			parent.just_door_idle = false

		states.door_idle:
			norm_sprite_anim_tree.travel("door_idle")
			if not Achievements.is_woof_encountered:
				parent.just_door_idle = true

		states.calm_down:
			norm_sprite_anim_tree.travel("calm_down")
			parent.set_back_destination()
			parent.ignore_mox = true

		states.flashed:
			norm_sprite_anim_tree.travel("flashed")
		states.annoyed:
			norm_sprite_anim_tree.travel("annoyed")
		states.angry:
			norm_sprite_anim_tree.travel("angry")
			parent.target_destination = Globals.get_player()
			parent.ignore_mox = false

		states.stunned:
			norm_sprite_anim_tree.travel("stunned")
			parent._creature_sounds("stop_all")

		states.afterglow:
			parent.hit_tolerance = 0
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim_tree.travel("calm_down")

		states.head_turn:
			norm_sprite_anim_tree.travel("head_turn")

		states.disabled:
			parent.get_node("lightVignette").hide()
			norm_sprite_anim_tree.travel("idle")

		states.idle:
			parent._creature_sounds("stop_all")
			if not parent.is_disabled:
				norm_sprite_anim_tree.travel("idle")
			else:
				print(parent.get_name(), ": is disabled. AnimationTree cannot travel.")
			parent.modify_default_speed()
		
			
			if Globals.is_woof_jazz and not parent.get_node("jazz").is_playing()\
			and Achievements.is_woof_encountered:
				parent.get_node("jazz").play()
				SoundManager.set_music_effect("none")
			
			
			if Achievements.is_allow_wolf_in_mall:
				if parent.should_start_time_before_walk and not parent.is_in_walk_end_point():
					parent.start_walk_timer()
			
			parent.flip_wolf_sprite("idle")

		states.self_saucy:
			parent._creature_sounds("stop_all")
		states.chase:
			norm_sprite_anim_tree.travel("angry")
			pass

func _exit_state(old_state, new_state):
	match old_state:
		states.afterglow:
			parent.afterglow = false
		states.self_saucy:
			parent.self_saucy = false
		states.stunned:
			parent.set_stunned(false)
			parent.set_can_saucy(true)
		states.idle:
			pass
		states.walk:
			parent.just_door_idle = false
			pass

func fiddle_parent_state():
	parent.enemy_state = states.keys()[state]
	parent.get_node("state").text = "state: " + parent.enemy_state + "\n"

	var stateMachine = parent.get_node("normSprite/AnimationTree").get("parameters/playback");
	parent.get_node("state").text += "animation: " + str(stateMachine.get_current_node()) + "\n"
	parent.get_node("state").text += "is_hug: " + str(parent.is_hug) + "\n"
	
	parent.get_node("state").text += str(parent.player) + "\n"
	parent.get_node("state").text += str("should_start_time_before_walk: ", parent.should_start_time_before_walk) + "\n"
	parent.get_node("state").text += str("should_walk: ", parent.should_walk) + "\n"
	parent.get_node("state").text += str("just_door_idle: ", parent.just_door_idle) + "\n"
	
