extends Node


func _ready():
	pass


func main(value: Dictionary) -> void :
	Globals.is_woof_jazz = value["value"]
