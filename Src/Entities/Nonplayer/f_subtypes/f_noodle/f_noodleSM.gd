extends NonplayerStateMachine


func _ready():
	_generic_ready()
	add_state("plop_to_ground")
	if parent.is_disabled:
		call_deferred("set_state", states.disabled)
	else:
		call_deferred("set_state", states.plop_to_ground)

func _state_logic(delta):

	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	parent._handle_movement()
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow, 
		states.plop_to_ground].has(state):
		parent._Nonplayer_direction(false)
		
	elif state == states.chase:
		parent._chase_player()
		parent._should_jump()
		parent._Nonplayer_direction(true)
		parent._check_attackRange_when_creature_turn()
	
	elif state == states.self_saucy:
		parent._Nonplayer_direction(false)

func _get_transition(_delta):
	match state:
		states.idle:
			if parent.is_disabled: return states.disabled
			if parent._can_afterglow(): return states.afterglow
			if parent.should_plop_to_ground: return states.plop_to_ground
			if (parent._can_chase()):
				return states.chase
			if parent._should_stun(): return states.stunned

		states.chase:
			if SettingsManager.is_exploration_mode: return states.idle
			if parent._should_stop_chase(): return states.idle
			if parent.should_plop_to_ground: return states.plop_to_ground
			
			

		states.plop_to_ground:
			if parent.is_disabled: return states.disabled
			if not parent.should_plop_to_ground: return states.idle
			
		states.afterglow:
			if parent._is_afterglow_timer_finished():
				return states.idle
			if parent._should_stun(): return states.stunned
		
		states.self_saucy:
			if parent._should_return_to_idle():
				return states.idle
			if parent._should_stun():
				return states.stunned

		states.stunned:
			if parent._should_return_stun_to_idle():
				return states.idle
	return null

func _enter_state(new_state, old_state):

	fiddle_parent_state()
	var norm_sprite_anim_tree = parent.get_node("normSprite/AnimationTree").get("parameters/playback")

	match new_state:
		states.attack: pass
		states.disabled:
			parent.get_node("lightVignette").hide()
			norm_sprite_anim_tree.travel("idle")
		states.chase:
			norm_sprite_anim_tree.travel("run")
			pass
		states.idle:
			parent.plop_to_ground(false)
			parent._creature_sounds("stop_all")
			if not parent.is_disabled:
				norm_sprite_anim_tree.travel("idle")
			else:
				print(parent.get_name(), ": is disabled. AnimationTree cannot travel.")
			parent.modify_default_speed()
			pass
		states.plop_to_ground:
			norm_sprite_anim_tree.travel("plop_to_ground")
			parent.plop_to_ground(true)
			pass
		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim_tree.travel("run")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
		states.stunned:
			norm_sprite_anim_tree.travel("run")
			parent._creature_sounds("stop_all")
