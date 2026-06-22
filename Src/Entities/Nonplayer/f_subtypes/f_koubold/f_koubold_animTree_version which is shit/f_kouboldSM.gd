extends NonplayerStateMachine




func _ready():
	_generic_ready()
	add_state("look_down")
	add_state("alert")

	
	add_state("turn")
	add_state("run_away")
	add_state("climb")
	
	call_deferred("set_state", states.look_down)

func _state_logic(delta):
	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	parent._handle_movement()
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow, states.climb].has(state):
		parent._Nonplayer_direction(false)
		
	elif [states.chase, states.run_away].has(state):
		if state == states.chase:
			parent._chase_player()
		else:
			parent._run_away()
		parent._should_jump()
		parent._Nonplayer_direction(true)
		parent._check_attackRange_when_creature_turn()
	
	elif state == states.self_saucy:
		parent._Nonplayer_direction(false)






func _get_transition(_delta):
	if parent.is_disabled: return states.disabled
	match state:
		states.look_down:
			
			if parent.seen_player: return states.alert
				
		states.alert:
			
			
			if parent.is_player_near_chasing_range: return states.turn

		states.turn:
			
			if parent.norm_sprite_anim_finished:
				return states.run_away

		states.run_away:
			
			if parent.ceiling_raycast.is_colliding()\
			and parent.climb_timer.is_stopped():
				return states.climb

		states.idle:
			if parent._can_afterglow(): return states.afterglow
			if parent._should_stun(): return states.stunned
			if parent.idle_chase_timer.is_stopped(): return states.chase
			
			

		states.climb:
			
			if parent.norm_sprite_anim_finished\
			and parent.idle_chase_timer.is_stopped():
				return states.chase

		states.chase:
			
			
			if parent.just_shot_at: return states.run_away
			
			if parent._should_self_saucy(): return states.self_saucy
		
		
		states.afterglow:
			
			if parent._is_afterglow_timer_finished(): return states.run_away
			if parent._should_stun(): return states.run_away
		
		states.self_saucy:
			
			if parent._should_return_to_idle(): return states.run_away
			if parent._should_stun(): return states.run_away

		states.stunned:
			
			if parent._should_return_stun_to_idle(): return states.run_away
	return null


func _enter_state(new_state, old_state):
	fiddle_parent_state()
	var anim_state_machine = parent.anim_state_machine

	match new_state:
		states.look_down:
			parent.looked_down = true
			anim_state_machine.travel("look_down")

		states.alert:
			anim_state_machine.travel("alert")
			pass

		states.turn:
			anim_state_machine.travel("turn")
			parent.climb_timer.start(parent.climb_cooldown)
			pass
	
		states.run_away:
			parent.climb_timer.start(parent.climb_cooldown)
			anim_state_machine.travel("run")

		states.climb:
			
			anim_state_machine.travel("climb")
			parent._set_detect_range(false)
			parent.just_shot_at = false

		states.chase:
			anim_state_machine.travel("run")
			parent._set_detect_range(true)

		states.idle:
			parent.idle_chase_timer.start(parent.chase_cooldown)
			parent._creature_sounds("stop_all")
			anim_state_machine.travel("idle_stare")
			parent.modify_default_speed()
			parent._set_detect_range(true)


		
		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			anim_state_machine.travel("idle_stare")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
			anim_state_machine.travel("self_saucy")
		states.stunned:
			anim_state_machine.travel("stunned")
			parent._creature_sounds("stop_all")


func _exit_state(old_state, new_state):
	match old_state:
		states.chase:
			pass
		states.look_down:
			parent.looked_down = false
		states.afterglow:
			parent.afterglow = false
		states.self_saucy:
			parent.self_saucy = false
		states.stunned:
			parent.set_stunned(false)
			parent.set_can_saucy(true)
