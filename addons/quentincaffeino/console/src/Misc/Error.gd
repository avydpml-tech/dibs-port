

var _message


var _code




func _init(message, code = null):
		self._message = message
		self._code = code



func get_message():
		return self._message



func get_code():
		return self._code



func to_string():
		return self._message
