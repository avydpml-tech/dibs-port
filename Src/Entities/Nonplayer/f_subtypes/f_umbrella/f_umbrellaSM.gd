extends NonplayerStateMachine






func _ready():
	_generic_ready()
	add_state("drop_tentacles")

func _state_logic(delta):

	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	
	parent.canDie()
		
	if state == states.chase:
		parent._check_if_player_in_range()
		parent._check_attackRange_when_creature_turn()


func _get_transition(_delta):
	match state:
		states.idle:
			if parent.is_disabled: return states.disabled
			if parent._can_afterglow(): return states.afterglow
			if parent.should_drop_tentacles: return states.drop_tentacles
			if (parent._can_chase()):
				return states.chase
			if parent._should_stun(): return states.stunned

		states.chase:
			if SettingsManager.is_exploration_mode: return states.idle
			if parent._should_stop_chase(): return states.idle
			if parent.should_drop_tentacles: return states.drop_tentacles
			
			

		states.drop_tentacles:
			if not parent.should_drop_tentacles: return states.idle
			
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
		states.chase:
			
			
			pass

		states.idle:
			parent._creature_sounds("stop_all")
			if not parent.is_disabled:
				norm_sprite_anim_tree.travel("idle")
			else:
				print(parent.get_name(), ": is disabled. AnimationTree cannot travel.")
			pass
		
		states.drop_tentacles:
			norm_sprite_anim_tree.travel("tentacles_drop")
		
		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim_tree.travel("idle")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
			
		states.stunned:
			norm_sprite_anim_tree.travel("idle")
			parent._creature_sounds("stop_all")
		states.disabled:
			parent.disable_creature()
			parent._creature_sounds("stop_all")






func fiddle_parent_state():
	parent.enemy_state = states.keys()[state] + "\n"\
	+ str(parent.player) + "\n"\
	+ str(parent.is_player_near_chasing_range) + "\n"

	parent.get_node("state").text = parent.enemy_state
	
