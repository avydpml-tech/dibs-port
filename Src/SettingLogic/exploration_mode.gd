extends Node


func main(value: Dictionary) -> void :
	SettingsManager.is_exploration_mode = value["value"]