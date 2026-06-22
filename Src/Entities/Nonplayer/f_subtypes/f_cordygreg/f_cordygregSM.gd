extends NonplayerStateMachine








func _ready():
	_generic_ready()

func _state_logic(delta):

	if [states.disabled].has(state): return

	parent._apply_gravity(delta)
	parent._apply_movement()
	
	parent.canDie()
	
	if [states.idle, states.stunned, states.afterglow].has(state):
		parent._Nonplayer_direction(false)
		
	elif state == states.chase:
		parent._check_if_player_in_range()
		parent._Nonplayer_direction(false)
		parent._check_attackRange_when_creature_turn()
	
	elif state == states.self_saucy:
		
		parent._Nonplayer_direction(false)
		pass






func _enter_state(new_state, old_state):
	fiddle_parent_state()
	var norm_sprite_anim = parent.norm_sprite_anim

	match new_state:
		states.attack: pass
		states.chase:
			parent._creature_sounds("screech")
			norm_sprite_anim.play("run")
		
		states.idle:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("idle")
			parent.modify_default_speed()

		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim.play("idle")

		states.self_saucy:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("self_saucy")
		states.stunned:
			norm_sprite_anim.play("idle")
			parent._creature_sounds("stop_all")
		states.disabled:
			parent.disable_creature()
			parent._creature_sounds("stop_all")
