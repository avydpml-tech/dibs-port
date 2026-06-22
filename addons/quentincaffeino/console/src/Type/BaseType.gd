
enum CHECK\
{
	OK, 
	FAILED, 
	CANCELED
}



var _name



func _init(name):
	self._name = name







func check(value):
	return CHECK.OK





func normalize(value):
	return value



func to_string():
	return self._name
