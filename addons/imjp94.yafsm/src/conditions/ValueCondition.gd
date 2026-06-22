tool 
extends "Condition.gd"

signal comparation_changed(new_comparation)
signal value_changed(new_value)


enum Comparation{
	EQUAL, 
	INEQUAL
	GREATER, 
	LESSER, 
	GREATER_OR_EQUAL, 
	LESSER_OR_EQUAL
}

const COMPARATION_SYMBOLS = [
	"==", 
	"!=", 
	">", 
	"<", 
	"≥", 
	"≤"
]

export (Comparation) var comparation = Comparation.EQUAL setget set_comparation

func _init(p_name = "", p_comparation = Comparation.EQUAL):
	._init(p_name)
	comparation = p_comparation

func set_comparation(c):
	if comparation != c:
		comparation = c
		emit_signal("comparation_changed", c)
		emit_signal("display_string_changed", display_string())


func set_value(v):
	pass


func get_value():
	pass


func get_value_string():
	return get_value()


func compare(v):
	if v == null:
		return false

	match comparation:
		Comparation.EQUAL:
			return v == get_value()
		Comparation.INEQUAL:
			return v != get_value()
		Comparation.GREATER:
			return v > get_value()
		Comparation.LESSER:
			return v < get_value()
		Comparation.GREATER_OR_EQUAL:
			return v >= get_value()
		Comparation.LESSER_OR_EQUAL:
			return v <= get_value()


func display_string():
	return "%s %s %s" % [.display_string(), COMPARATION_SYMBOLS[comparation], get_value_string()]
