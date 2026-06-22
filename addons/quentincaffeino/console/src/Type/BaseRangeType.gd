
extends "res://addons/quentincaffeino/console/src/Type/BaseRegexCheckedType.gd"



var _min_value


var _max_value


var _step






func _init(name, min_value, max_value, step).(name, "^[+-]?([0-9]*[\\.\\,]?[0-9]+|[0-9]+[\\.\\,]?[0-9]*)([eE][+-]?[0-9]+)?$"):
	self._min_value = min_value
	self._max_value = max_value
	self._step = step



func get_min_value():
	return self._min_value



func set_min_value(min_value):
	self._min_value = min_value
	return self



func get_max_value():
	return self._max_value



func set_max_value(max_value):
	self._max_value = max_value
	return self



func get_step():
	return self._step



func set_step(step):
	self._step = step
	return self



func to_string():
	var name = self._name + "(" + str(self._min_value) + "-" + str(self._max_value)

	if self._step != 1:
		name += ", step: " + str(self._step)

	return name + ")"
