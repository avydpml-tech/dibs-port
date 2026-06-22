extends NonplayerStateMachine




func _ready():
	_generic_ready()
	add_state("look_down")
	add_state("alert")
	add_state("grappled_player")

	
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
	
	if [states.idle, states.stunned, states.afterglow, 
			states.climb, states.grappled_player].has(state):
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
















				














































		
		
		
		
		
		
		
		
		

		
		
		
	


func _enter_state(new_state, old_state):
	fiddle_parent_state()
	var norm_sprite_anim = parent.norm_sprite_anim

	match new_state:
		states.look_down:
			parent.looked_down = true
			norm_sprite_anim.play("look_down")

		states.alert:
			norm_sprite_anim.play("alert")

		states.turn:
			norm_sprite_anim.play("turn")
			parent.climb_timer.start(parent.climb_cooldown)
	
		states.run_away:
			parent.climb_timer.start(parent.climb_cooldown)
			norm_sprite_anim.play("run")

		states.climb:
			
			parent.norm_sprite_anim.seek(0)
			norm_sprite_anim.play("climb")
			parent._set_detect_range(false)
			parent.just_shot_at = false

		states.chase:
			norm_sprite_anim.play("run")
			parent._set_detect_range(true)
			parent.self_saucy = false

		states.idle:
			parent.idle_chase_timer.start(parent.chase_cooldown)
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("idle_stare")
			parent.modify_default_speed()
			parent._set_detect_range(true)


		
		states.afterglow:
			parent._start_afterglow_timer(parent.afterglow_time)
			norm_sprite_anim.play("idle_stare")
			pass
		states.self_saucy:
			parent._creature_sounds("stop_all")
			norm_sprite_anim.play("self_saucy")
		states.stunned:
			norm_sprite_anim.play("stunned")
			parent._creature_sounds("stop_all")


func _exit_state(old_state, new_state):
	match old_state:
		states.climb:
			parent.show()
		states.chase:
			parent.force_chase(false, "KouboldSM.gd")
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
