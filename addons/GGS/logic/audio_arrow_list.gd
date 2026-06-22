extends Node








func main(value: Dictionary) -> void :
	var volume: float = range_lerp(value["value"], 0, value["list_length"], 0, 1)
	var bus_index: int = AudioServer.get_bus_index(value["bus_name"])
	AudioServer.set_bus_volume_db(bus_index, linear2db(volume))
