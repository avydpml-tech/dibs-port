extends Node






func main(value: Dictionary) -> void :
	var bus_index: int = AudioServer.get_bus_index(value["bus_name"])
	AudioServer.set_bus_volume_db(bus_index, linear2db(value["value"]))
