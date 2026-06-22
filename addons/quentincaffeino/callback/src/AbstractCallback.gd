
extends Reference

const Utils = preload("./Utils.gd")
const errors = preload("../assets/translations/errors.en.gd").messages



var _target


var _type


var _bind_argv




func _init(target, type):
	self._target = target
	self._type = type
	self._bind_argv = []



func get_target():
	return self._target



func get_type():
	return self._type




func ensure():
	pass




func bind(argv = []):
	for _argv in argv:
		self._bind_argv.append(_argv)




func call(argv = []):
	pass




func _get_args(args = []):
	var new_args = self._bind_argv.duplicate()

	for arg in args:
		new_args.append(arg)

	return new_args
