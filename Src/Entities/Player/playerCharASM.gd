extends StateMachine










func _ready():
	add_state("none")
	add_state("shoot")
	add_state("dead_trigger")
	add_state("reload")
	call_deferred("set_state", states.none)


func _get_transition(_delta):
	match state:
		states.none:
			if parent.player_state == "aim":
				if Input.is_action_just_pressed("ui_left_mouse"):
					if can_shoot():
						return states.shoot
					elif parent.ammo_count == 0:
						return states.dead_trigger
				
		states.shoot:
			return states.none
		
		states.dead_trigger:
			return states.none

		states.reload:
			if parent.reload_timer.is_stopped():
				return states.none
				
		

onready var camera = parent.get_node("playerCamera")
func _enter_state(new_state, old_state):
	match new_state:
		states.none:
			
			pass
		states.shoot:
			parent._player_attack()
			parent.fire_delay.start()
			parent._pistol_sounds("fire")
			parent.check_blaster_light_state()

		states.dead_trigger:
			parent._pistol_sounds("dead_trigger")
			if not parent.is_blaster_enabled:
				parent._pistol_sounds("deny_beep")

		states.reload:
			pass


func _exit_state(old_state, new_state):
	match old_state:
		states.reload:
			pass
	pass


func can_shoot() -> bool:
	
	if (parent.ammo_count > 0 or SettingsManager.is_infinite_ammo_mode)\
	and parent.fire_delay.is_stopped():
		return true
	return false


func can_jump() -> bool:
	var main_states = parent.state_machine.states
	
	return not [main_states.jump, main_states.fall].has(parent.state_machine.state)
