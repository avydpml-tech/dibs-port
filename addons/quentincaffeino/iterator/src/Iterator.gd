
extends Reference

const CallbackBuilder = preload("res://addons/quentincaffeino/callback/src/CallbackBuilder.gd")



var _object_get_value_cb


var _object_get_length_cb


var _iteration_current_index = 0


var length setget _set_readonly, length





func _init(target, get_value_field = "get", get_length_field = "size"):
	_object_get_value_cb = CallbackBuilder.new(target).set_name(get_value_field).build()
	_object_get_length_cb = CallbackBuilder.new(target).set_name(get_length_field).build()



func length():
	return self._object_get_length_cb.call()




func _get(index):
	return self._object_get_value_cb.call([index])




func first():
	if self.length:
		self._iteration_current_index = 0
		return self._get(self._iteration_current_index)

	return null




func last():
	if self.length:
		self._iteration_current_index = self.length - 1
		return self._get(self._iteration_current_index)

	return null




func key():
	if self.length:
		return self._iteration_current_index

	return null




func next():
	if self.length and self._iteration_current_index < self.length - 1:
		self._iteration_current_index += 1
		return self._get(self._iteration_current_index)

	return null




func previous():
	if self.length and self._iteration_current_index > 0:
		self._iteration_current_index -= 1
		return self._get(self._iteration_current_index)

	return null




func current():
	if self.length:
		return self._get(self._iteration_current_index)

	return null




func _iter_init(arg):
	self._iteration_current_index = 0
	return self._iteration_current_index < self.length




func _iter_next(arg):
	self._iteration_current_index += 1
	return self._iteration_current_index < self.length




func _iter_get(arg = null):
	return self._get(self._iteration_current_index)



func _set_readonly(value):
	print("qc/iterator: Iterator: Attempted to set readonly value, ignoring.")
