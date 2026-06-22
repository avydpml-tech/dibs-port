extends Node2D





export (String) var something = ""
export (bool) var value = ""

func _enter_tree():
	Globals.set(something, value)