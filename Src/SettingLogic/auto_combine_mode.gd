extends Node

func main(value: Dictionary) -> void :
	SettingsManager.is_auto_combine_ammo_mode = value["value"]
