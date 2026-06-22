extends Node


func main(value: Dictionary) -> void :
	SettingsManager.is_sfw_mode = value["value"]
