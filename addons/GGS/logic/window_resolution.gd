extends Node




var resolution_list: Array = [
	Vector2(640, 360), 
	Vector2(1280, 720), 
	Vector2(1920, 1080), 
]


func main(value: Dictionary) -> void :
	OS.window_size = resolution_list[value["value"]]
	OS.center_window()
