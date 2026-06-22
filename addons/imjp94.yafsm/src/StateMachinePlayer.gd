tool 
extends "StackPlayer.gd"
const State = preload("states/State.gd")

signal transited(from, to)
signal entered(to)
signal exited(from)
signal updated(state, delta)


enum ProcessMode{
	PHYSICS, 
	IDLE, 
	MANUAL
}

export (Resource) var state_machine
export (bool) var active = true setget set_active
export (bool) var autostart = true
export (ProcessMode) var process_mode = ProcessMode.IDLE setget set_process_mode

var _is_started = false
var _parameters
var _local_parameters
var _is_update_locked = true
var _was_transited = false
var _is_param_edited = false


func _init():
	if Engine.editor_hint:
		return

	_parameters = {}
	_local_parameters = {}
	_was_transited = true

func _get_configuration_warning():
	if state_machine:
		if not state_machine.has_entry():
			return "State Machine will not function properly without Entry node"
	else:
		return "State Machine Player is not going anywhere without default State Machine"
	return ""

func _ready():
	if Engine.editor_hint:
		return

	set_process(false)
	set_physics_process(false)
	call_deferred("_initiate")

func _initiate():
	if autostart:
		start()
	_on_active_changed()
	_on_process_mode_changed()

func _process(delta):
	if Engine.editor_hint:
		return

	_update_start()
	update(delta)
	_update_end()

func _physics_process(delta):
	if Engine.editor_hint:
		return

	_update_start()
	update(delta)
	_update_end()


func _transit():
	if not active:
		return
	
	if not _is_param_edited and not _was_transited:
		return

	var from = get_current()
	var local_params = _local_parameters.get(path_backward(from), {})
	var next_state = state_machine.transit(get_current(), _parameters, local_params)
	if next_state:
		if stack.has(next_state):
			reset(stack.find(next_state))
		else:
			push(next_state)
	var to = next_state
	_was_transited = not not next_state
	_is_param_edited = false
	_flush_trigger(_parameters)
	_flush_trigger(_local_parameters, true)

	if _was_transited:
		_on_state_changed(from, to)

func _on_state_changed(from, to):
	match to:
		State.ENTRY_STATE:
			emit_signal("entered", "")
		State.EXIT_STATE:
			set_active(false)
			emit_signal("exited", "")
	
	if to.ends_with(State.ENTRY_STATE) and to.length() > State.ENTRY_STATE.length():
		
		var state = path_backward(get_current())
		emit_signal("entered", state)
	elif to.ends_with(State.EXIT_STATE) and to.length() > State.EXIT_STATE.length():
		
		var state = path_backward(get_current())
		clear_param(state, false)
		emit_signal("exited", state)

	emit_signal("transited", from, to)


func _update_start():
	_is_update_locked = false


func _update_end():
	_is_update_locked = true


func _on_updated(delta, state):
	pass

func _on_process_mode_changed():
	if not active:
		return

	match process_mode:
		ProcessMode.PHYSICS:
			set_physics_process(true)
			set_process(false)
		ProcessMode.IDLE:
			set_physics_process(false)
			set_process(true)
		ProcessMode.MANUAL:
			set_physics_process(false)
			set_process(false)

func _on_active_changed():
	if Engine.editor_hint:
		return

	if active:
		_on_process_mode_changed()
		_transit()
	else:
		set_physics_process(false)
		set_process(false)



func _flush_trigger(params, nested = false):
	for param_key in params.keys():
		var value = params[param_key]
		if nested and value is Dictionary:
			_flush_trigger(value)
		if value == null:
			params.erase(param_key)

func reset(to = - 1, event = ResetEventTrigger.LAST_TO_DEST):
	.reset(to, event)
	_was_transited = true


func start():
	push(State.ENTRY_STATE)
	emit_signal("entered", "")
	_was_transited = true
	_is_started = true


func restart(is_active = true, preserve_params = false):
	reset()
	set_active(is_active)
	if not preserve_params:
		clear_param("", false)
	start()




func update(delta = get_physics_process_delta_time()):
	if not active:
		return
	if process_mode != ProcessMode.MANUAL:
		assert ( not _is_update_locked, "Attempting to update manually with ProcessMode.%s" % ProcessMode.keys()[process_mode])

	_transit()
	var current_state = get_current()
	_on_updated(current_state, delta)
	emit_signal("updated", current_state, delta)
	if process_mode == ProcessMode.MANUAL:
		
		if _was_transited:
			call_deferred("update")




func set_trigger(name, auto_update = true):
	set_param(name, null, auto_update)

func set_nested_trigger(path, name, auto_update = true):
	set_nested_param(path, name, null, auto_update)




func set_param(name, value, auto_update = true):
	var path = ""
	if "/" in name:
		path = path_backward(name)
		name = path_end_dir(name)
	set_nested_param(path, name, value, auto_update)

func set_nested_param(path, name, value, auto_update = true):
	if path.empty():
		_parameters[name] = value
	else:
		var local_params = _local_parameters.get(path)
		if local_params is Dictionary:
			local_params[name] = value
		else:
			local_params = {}
			local_params[name] = value
			_local_parameters[path] = local_params
	_on_param_edited(auto_update)




func erase_param(name, auto_update = true):
	var path = ""
	if "/" in name:
		path = path_backward(name)
		name = path_end_dir(name)
	return erase_nested_param(path, name, auto_update)

func erase_nested_param(path, name, auto_update = true):
	var result = false
	if path.empty():
		result = _parameters.erase(name)
	else:
		result = _local_parameters.get(path, {}).erase(name)
	_on_param_edited(auto_update)
	return result




func clear_param(path = "", auto_update = true):
	if path.empty():
		_parameters.clear()
	else:
		_local_parameters.get(path, {}).clear()
		
		for param_key in _local_parameters.keys():
			if param_key.begins_with(path):
				_local_parameters.erase(param_key)


func _on_param_edited(auto_update = true):
	_is_param_edited = true
	if process_mode == ProcessMode.MANUAL and auto_update and _is_started:
		update()



func get_param(name, default = null):
	var path = ""
	if "/" in name:
		path = path_backward(name)
		name = path_end_dir(name)
	return get_nested_param(path, name, default)

func get_nested_param(path, name, default = null):
	if path.empty():
		return _parameters.get(name, default)
	else:
		var local_params = _local_parameters.get(path, {})
		return local_params.get(name, default)


func get_params():
	return _parameters.duplicate()



func has_param(name):
	var path = ""
	if "/" in name:
		path = path_backward(name)
		name = path_end_dir(name)
	return has_nested_param(path, name)

func has_nested_param(path, name):
	if path.empty():
		return name in _parameters
	else:
		var local_params = _local_parameters.get(path, {})
		return name in local_params


func is_entered():
	return State.ENTRY_STATE in stack


func is_exited():
	return get_current() == State.EXIT_STATE

func set_active(v):
	if active != v:
		if v:
			if is_exited():
				push_warning("Attempting to make exited StateMachinePlayer active, call reset() then set_active() instead")
				return
		active = v
		_on_active_changed()

func set_process_mode(mode):
	if process_mode != mode:
		process_mode = mode
		_on_process_mode_changed()

func get_current():
	var v = .get_current()
	return v if v else ""

func get_previous():
	var v = .get_previous()
	return v if v else ""



static func node_path_to_state_path(node_path):
	var p = node_path.replace("root", "")
	if p.begins_with("/"):
		p = p.substr(1)
	return p



static func state_path_to_node_path(state_path):
	var path = state_path
	if path.empty():
		path = "root"
	else:
		path = str("root/", path)
	return path


static func path_backward(path):
	return path.substr(0, path.rfind("/"))


static func path_end_dir(path):
	return path.right(path.rfind("/") + 1)
