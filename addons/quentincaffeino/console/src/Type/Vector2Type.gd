
extends "res://addons/quentincaffeino/console/src/Type/BaseRegexCheckedType.gd"



var _normalized_value


func _init().("Vector2", "^[+-]?([0-9]*[\\.\\,]?[0-9]+|[0-9]+[\\.\\,]?[0-9]*)([eE][+-]?[0-9]+)?$"):
	pass




func check(value):
	var values = str(value).split(",", false, 2)
	if values.size() < 2:
		if values.size() == 1:
			values.append("0")
		else:
			return CHECK.FAILED

	
	for i in range(2):
		if .check(values[i]) == CHECK.FAILED:
			return CHECK.FAILED

	
	self._normalized_value = Vector2(values[0], values[1])

	return CHECK.OK




func normalize(value):
	return self._normalized_value
