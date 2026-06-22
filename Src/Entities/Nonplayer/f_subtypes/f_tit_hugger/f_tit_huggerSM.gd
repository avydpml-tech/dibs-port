extends NonplayerStateMachine


func _ready():
	add_state("jump")
	add_state("grappled_player")
	_generic_ready()

func _state_logic(delta):

	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow].has(state):
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
			if parent.is_asleep: return states.sleep
			if parent.is_grappling_player: return states.grappled_player
			if parent._should_self_saucy(): return states.self_saucy
			if parent._can_afterglow(): return states.afterglow
			if parent._can_chase(): return states.chase
			if parent._should_stun(): return states.stunned

		states.chase:
			if SettingsManager.is_exploration_mode: return states.idle
			if parent._should_self_saucy(): return states.self_saucy
			if parent._should_stop_chase(): return states.idle
			if parent.jump_timer.is_stopped(): return states.jump
			if parent._should_stun(): return states.stunned

		states.jump:
			if parent.is_on_floor(): return states.idle

		states.grappled_player:
			if not parent.is_grappling_player: return states.idle

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

		states.sleep:
			if not parent.is_asleep: return states.idle

	return null

func _enter_state(new_state, old_state):
	parent.enemy_state = new_state

	fiddle_parent_state()

	var norm_sprite_anim = parent.norm_sprite_anim

	match new_state:
		states.attack: pass
		states.chase:
			parent.jump_timer.start()
			
			norm_sprite_anim.play("run")
		states.idle:
			parent.on_floor()
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("idle")
			parent.modify_default_speed()

		states.jump:
			parent.check_if_player_in_attack_body()
			parent.jump_to_player()
			parent._creature_sounds("screech")
			norm_sprite_anim.play("fall")

		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim.play("idle")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("self_saucy")
		states.stunned:
			norm_sprite_anim.play("stunned")
			parent._creature_sounds("stop_all")
