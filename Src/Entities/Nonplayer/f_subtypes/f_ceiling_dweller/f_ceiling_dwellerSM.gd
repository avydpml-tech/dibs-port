extends NonplayerStateMachine








func _ready():
	_generic_ready()

func _state_logic(delta):

	if [states.disabled].has(state): return
	
	parent._apply_gravity(delta)
	parent._apply_movement()
	
	parent.canDie()
		
	if state == states.chase:
		parent._check_if_player_in_range()
		parent._check_attackRange_when_creature_turn()



func _enter_state(new_state, old_state):
	fiddle_parent_state()
	var norm_sprite_anim = parent.norm_sprite_anim

	match new_state:
		states.attack: pass
		states.chase:
			
			
			pass
			
		states.idle:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("idle")
			parent.norm_sprite_2_anim.play("idle")
			parent.modify_default_speed()
			pass
		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim.play("idle")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
		states.stunned:
			parent._creature_sounds("stop_all")
		states.disabled:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.stop()
			parent.norm_sprite_2_anim.stop()
			
	
