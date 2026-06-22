extends Node



var scr = OS.get_current_screen()
var screen_res = OS.get_screen_size(scr)


var resolution_list: Array = [
	screen_res, 
	Vector2(854, 480), 
	Vector2(1280, 720), 
	Vector2(1920, 1080), 
]


func main(value: Dictionary) -> void :
	OS.window_size = resolution_list[value["value"]]
	if value["value"] == 0:
		OS.set_window_position(Vector2(0, 0))
	else:
		OS.center_window()
