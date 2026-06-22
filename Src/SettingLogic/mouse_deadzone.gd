extends Node

func main(value: Dictionary) -> void :
	SettingsManager.one_handed_deadzone = value["value"]
