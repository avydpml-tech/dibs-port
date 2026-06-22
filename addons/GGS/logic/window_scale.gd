extends Node





var BASE_SIZE: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"), 
	ProjectSettings.get_setting("display/window/size/height")
)


func main(value: Dictionary) -> void :
	OS.window_size = BASE_SIZE * (value["value"] + value["min_scale"])
	OS.center_window()
