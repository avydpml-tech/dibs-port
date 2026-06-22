extends Node






func main(value: Dictionary) -> void :
	var bus_index: int = AudioServer.get_bus_index(value["bus_name"])
	AudioServer.set_bus_mute(bus_index, value["value"])
