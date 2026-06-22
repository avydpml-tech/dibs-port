extends NonplayerStateMachine




func _ready():
	_generic_ready()

func _state_logic(delta):

	if [states.disabled].has(state): return

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
	
	elif state == states.self_saucy:
		
		parent._Nonplayer_direction(false)
