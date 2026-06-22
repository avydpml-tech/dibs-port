extends Node

signal pushed(to)
signal popped(from)


enum ResetEventTrigger{
	NONE = - 1, 
	ALL = 0, 
	LAST_TO_DEST = 1
}

var current setget , get_current
var stack setget set_stack, get_stack


func _init():
	stack = []


func push(to):
	var from = get_current()
	stack.push_back(to)
	_on_pushed(from, to)
	emit_signal("pushed", to)


func pop():
	var to = get_previous()
	var from = stack.pop_back()
	_on_popped(from, to)
	emit_signal("popped", from)


func _on_pushed(from, to):
	pass


func _on_popped(from, to):
	pass



func reset(to = - 1, event = ResetEventTrigger.ALL):
	assert (to > - 2 and to < stack.size(), "Reset to index(%d) out of bounds(%d)" % [to, stack.size()])
	var last_index = stack.size() - 1
	var first_state = ""
	var num_to_pop = last_index - to

	if num_to_pop > 0:
		for i in range(num_to_pop):
			first_state = get_current() if i == 0 else first_state
			match event:
				ResetEventTrigger.LAST_TO_DEST:
					stack.pop_back()
					if i == num_to_pop - 1:
						stack.push_back(first_state)
						pop()
				ResetEventTrigger.ALL:
					pop()
				_:
					stack.pop_back()
	elif num_to_pop == 0:
		match event:
			ResetEventTrigger.NONE:
				stack.pop_back()
			_:
				pop()

func set_stack(stack):
	push_warning("Attempting to edit read-only state stack directly. "\
	+ "Control state machine from setting parameters or call update() instead")


func get_stack():
	return stack.duplicate()

func get_current():
	return stack.back() if not stack.empty() else null

func get_previous():
	return stack[stack.size() - 2] if stack.size() > 1 else null
