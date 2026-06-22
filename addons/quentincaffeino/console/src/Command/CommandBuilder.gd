
extends Reference

const CallbackBuilder = preload("res://addons/quentincaffeino/callback/src/CallbackBuilder.gd")
const Callback = preload("res://addons/quentincaffeino/callback/src/Callback.gd")
const ArgumentFactory = preload("../Argument/ArgumentFactory.gd")
const Command = preload("Command.gd")



var _console


var _command_service


var _name


var _target


var _arguments


var _description







func _init(console, command_service, name, target, target_name = null):
	self._console = console
	self._command_service = command_service

	self._name = name
	self._target = self._initialize_target_callback(target, target_name)
	self._arguments = []
	self._description = null





func _initialize_target_callback(target, name = null):
	if target is Callback:
		return target

	name = name if name else self._name

	var callback = CallbackBuilder.new(target).set_name(name).build()

	if not callback:
		self._console.Log.error(\
		"CommandBuilder: Failed to create [b]`%s`[/b] command. Failed to create callback to target with method [b]`%s`[/b]." %
			[self._name, name])

	return callback






func add_argument(name, type = null, description = null):
	
	var argument_result = ArgumentFactory.create(name, type, description)
	var error = argument_result.get_error()
	if error:
		if error.get_code() != ArgumentFactory.FALLBACK_ERROR:
			self._console.Log.error(error.get_message())
			return self
		else:
			self._console.Log.warn(\
			"CommandBuilder: add_argument for command `%s` for argument `%s` failed with: %s" % [self._name, name, error.get_message()])

	var argument = argument_result.get_value()
	self._arguments.append(argument)
	return self




func set_description(description = null):
	self._description = description
	return self



func register():
	var command = Command.new(self._name, self._target, self._arguments, self._description)
	if not self._command_service.set(self._name, command):
		self._console.Log.error("CommandBuilder::register: Failed to create [b]`%s`[/b] command. Command already exists." % self._name)
