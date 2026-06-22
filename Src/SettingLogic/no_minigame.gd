extends Node



func _ready():
	pass


func main(value: Dictionary) -> void :
	Globals.is_minigame_active = value["value"]

