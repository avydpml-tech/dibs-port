extends Node

func main(value: Dictionary) -> void :
	var layout = "QWERTY" if value["value"] else "AZERTY"
	SettingsManager.keyboard_layout = layout
	SettingsManager.change_keyboard_layout(value["value"])

	
	
	
