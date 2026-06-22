
extends Reference


enum ASSIGNMENT\
{
	OK, 
	FAILED, 
	CANCELED
}



var _name


var _type


var _description


var _original_value


var _normalized_value





func _init(name, type, description = null):
	self._name = name
	self._type = type
	self._description = description



func get_name():
	return self._name



func get_type():
	return self._type



func get_value():
	return self._original_value




func set_value(value):
	self._original_value = value

	var check = self._type.check(value)
	if check == OK:
		self._normalized_value = self._type.normalize(value)

	return check



func get_normalized_value():
	return self._normalized_value



func describe():
	return "<%s:%s>" % [self._name, self._type.to_string()]
