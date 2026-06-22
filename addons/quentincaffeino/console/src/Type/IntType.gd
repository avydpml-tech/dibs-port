
extends "res://addons/quentincaffeino/console/src/Type/BaseRegexCheckedType.gd"


func _init().("Int", "^[+-]?\\d+$"):
	pass




func normalize(value):
	return int(self._reextract(value))
