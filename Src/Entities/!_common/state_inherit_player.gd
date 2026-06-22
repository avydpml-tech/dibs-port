extends StateMachine



func _ready():
				addState("sleep")
				addState("chase")
				addState("attack")
				call_deferred("set_state", states.sleep)
				
func stateLogic(delta):
				pass
				
func getTransition(delta):
				return null
				
func enterState(new_state, old_state):
				pass
				
func exitState(old_state, new_state):
				pass
