
extends Reference

const Utils = preload("./Utils.gd")
const Callback = preload("./Callback.gd")
const FuncRefCallback = preload("./FuncRefCallback.gd")
const errors = preload("../assets/translations/errors.en.gd").messages



var _target


var _name


var _type


var _bind_argv



func _init(target):
	self._target = target
	self._type = Utils.Type.UNKNOWN
	self._bind_argv = []




func set_name(name):
	self._name = name
	return self


func get_name():
	return self._name



func set_variable(name):
	self._name = name
	self._type = Utils.Type.VARIABLE
	return self



func set_method(name):
	self._name = name
	self._type = Utils.Type.METHOD
	return self




func set_type(type):
	self._type = type
	return self


func get_type():
	return self._type




func bind(argv = []):
	self._bind_argv = argv
	return self



func build():
	if typeof(self._target) != TYPE_OBJECT:
		print(errors["qc.callback.canCreate.first_arg"] %str(typeof(self._target)))
		return null

	if Utils.is_funcref(self._target):
		return FuncRefCallback.new(self._target)

	if typeof(self._name) != TYPE_STRING:
		print(errors["qc.callback.canCreate.second_arg"] %str(typeof(self._name)))
		return null

	if not self._type or self._type == Utils.Type.UNKNOWN:
		self._type = Utils.get_type(self._target, self._name)
		if self._type == Utils.Type.UNKNOWN:
			print(errors["qc.callback.target_missing_mv"] %[self._target, self._name])
			return null

	var callback = Callback.new(self._target, self._name, self._type)
	callback.bind(self._bind_argv)
	return callback
