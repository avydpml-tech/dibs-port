extends StateMachine

func _ready():
	
	add_state("idle")
	add_state("chase")
	add_state("fall")
	
	
	add_state("attack")
	add_state("angry")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent._apply_gravity(delta)
	parent._apply_movement()
	parent._handle_movement()
	parent._Nonplayer_direction()
	
	if state != states.idle:
		pass

	

func _get_transition(_delta):
	match state:
		states.idle:
			if parent._can_chase(): return states.chase

		states.chase:
			if parent._can_chase(): return states.idle
			if parent._can_attack(): return states.attack

		states.attack:
			if parent.is_on_floor(): return states.idle

		states.angry:
			if parent.attackSprite.finished():
				states.idle
		

	return null
