extends NonplayerStateMachine

func _ready():
	_generic_ready()
	
	add_state("hang")
	if not parent.is_disabled:
		call_deferred("set_state", states.hang)


func _state_logic(delta):
	
	if [states.disabled].has(state): return

	if state != states.hang:
		parent._apply_gravity(delta)
	
	parent._apply_movement()
	parent._handle_movement()
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow].has(state):
		parent._Nonplayer_direction(false)
		
	elif state == states.chase:
		parent._chase_player()
		parent._should_jump()
		parent._Nonplayer_direction(true)
		parent._check_attackRange_when_creature_turn()
	
	elif state == states.fall:
		parent._Nonplayer_direction(true)

	elif state == states.self_saucy:
		
		parent._Nonplayer_direction(false)
		pass

	fiddle_parent_state()



func _get_transition(_delta):
	match state:
		states.idle:
			if parent.is_disabled: return states.disabled
			if parent.is_asleep: return states.sleep
			if parent._can_afterglow(): return states.afterglow
			if parent._can_chase(): return states.chase
			if parent._should_stun(): return states.stunned

		states.fall:
			if parent.is_on_floor(): return states.idle
			

		states.hang:
			if parent._should_fall(): return states.fall

		states.chase:
			
			if SettingsManager.is_exploration_mode: return states.idle
			if parent._should_stop_chase(): return states.idle
			if parent._should_self_saucy(): return states.self_saucy
			if parent._should_stun(): return states.stunned

		states.afterglow:
			if parent._is_afterglow_timer_finished():
				return states.idle

		states.self_saucy:
			if parent._should_return_to_idle():
				return states.idle
			if parent._should_stun():
				return states.stunned
				
		states.stunned:
			if parent._should_return_stun_to_idle():
				return states.idle

		states.attack:
			if parent.is_on_floor(): return states.idle
			
		states.sleep:
			if not parent.is_asleep: return states.idle


	return null

	
func fiddle_parent_state():
	
	parent.enemy_state = states.keys()[state]
	parent.get_node("state").text = states.keys()[state] + str(parent.stun_timer.time_left)
