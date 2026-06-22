
const Error = preload("./Error.gd")



var _value


var _error




func _init(value, error = null):
	self._value = value

	if error is String:
		error = self.get_script().create_error(error)

	self._error = error



func get_value():
	return self._value



func get_error():
	return self._error


func has_error():
	return not not self._error




static func create_error(message):
	return Error.new(message)
