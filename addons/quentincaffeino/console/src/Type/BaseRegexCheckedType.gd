
extends "res://addons/quentincaffeino/console/src/Type/BaseType.gd"



var _pattern


var _regex




func _init(name, pattern).(name):
	self._pattern = pattern
	self._regex = RegEx.new()
	self._regex.compile(self._pattern)




func check(value):
	return CHECK.OK if self._reextract(value) else CHECK.FAILED




func _reextract(value):
	var rematch = self._regex.search(value)

	if rematch and rematch is RegExMatch:
		return rematch.get_string()

	return null
