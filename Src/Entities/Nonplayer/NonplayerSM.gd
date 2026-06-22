extends StateMachine
class_name NonplayerStateMachine






func _generic_ready():
	
	add_state("idle")
	add_state("chase")
	add_state("fall")
	add_state("disabled")
	
	
	add_state("self_saucy")
	add_state("sleep")
	add_state("stunned")
	add_state("attack")
	add_state("grappled_player")

	add_state("afterglow")

	
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent._apply_gravity(delta)

	if state == states.chase:
		parent._chase_player()
		parent._stop()

	parent._apply_velocity()


func _get_transition(_delta):
	match state:
		states.idle:
			if parent.is_disabled: return states.disabled
			if parent.is_asleep: return states.sleep
			if parent._can_afterglow(): return states.afterglow
			if parent._can_chase(): return states.chase
			if parent._should_stun(): return states.stunned

		states.chase:
			if SettingsManager.is_exploration_mode: return states.idle
			if parent._should_stop_chase(): return states.idle
			if parent._should_self_saucy(): return states.self_saucy
			if parent._should_stun(): return states.stunned

		states.afterglow:
			if parent._is_afterglow_timer_finished():
				return states.idle
			if parent._should_stun(): return states.stunned
		
		states.self_saucy:
			if parent._should_return_to_idle():
				return states.idle
			if parent._should_stun():
				return states.stunned

		states.sleep:
			if not parent.is_asleep: return states.idle

			
			
			

			
			

			
			
			
			

			
			pass

		states.stunned:
			if parent._should_return_stun_to_idle():
				return states.idle
	return null
	

func _enter_state(new_state, old_state):
	fiddle_parent_state()
	var norm_sprite_anim = parent.norm_sprite_anim

	

	match new_state:
		states.chase:
			parent._creature_sounds("screech")
			parent._creature_sounds("skitter")
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
			norm_sprite_anim.play("stunned")
			parent._creature_sounds("stop_all")
	
		states.sleep:
			norm_sprite_anim.play("idle")
			parent._creature_sounds("stop_all")



func _exit_state(old_state, new_state):
	match old_state:
		states.afterglow:
			parent.afterglow = false
		states.self_saucy:
			parent.self_saucy = false
		states.stunned:
			parent.set_stunned(false)
			parent.set_can_saucy(true)
	
	
func fiddle_parent_state():
	parent.enemy_state = states.keys()[state]
	parent.get_node("state").text = parent.enemy_state + "\n"
	parent.get_node("state").text += str(parent.player)
