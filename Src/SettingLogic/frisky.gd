extends Node








func _ready():
	pass


func main(value: Dictionary) -> void :
	SettingsManager.is_frisky = value["value"]



