extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	test()
	
var is_show_cursor: bool = false
func test():
	is_show_cursor = Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE

var cursor_list = [
	load("res://Assets/1_Visual/2_UI/Cursors/crosshair001_enlarged.png"), 
	load("res://Assets/1_Visual/2_UI/Cursors/crosshair_left.png"), 
	load("res://Assets/1_Visual/2_UI/Cursors/crosshair_right.png"), 
	load("res://Assets/1_Visual/2_UI/Cursors/crosshair066_small.png"), 
]

func set_visible( var boolean: bool):
	match boolean:
		false: Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		true: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_cursor( var cursor = null):
	

	match cursor:
		"dot": Input.set_custom_mouse_cursor(cursor_list[0], 0, Vector2(36, 36))
		"walk_left": Input.set_custom_mouse_cursor(cursor_list[1], 0, Vector2(36, 36))
		"walk_right": Input.set_custom_mouse_cursor(cursor_list[2], 0, Vector2(36, 36))
		"scoped": Input.set_custom_mouse_cursor(cursor_list[ - 1], 0, Vector2(36, 36))
		_: Input.set_custom_mouse_cursor(null)
