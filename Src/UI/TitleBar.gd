extends Control

\
\
\
\
\
"\r\n~~~~~~~~~~~~~~~~~~~~~~~~~ NOTE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n 640 x 360 causes the window to jitter if you try to use\r\n the TitleBar.\r\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n"

var following = false
var can_drag = false
var dragging_start_position = Vector2()

func _ready():
	$ShowWhenHover.hide()

func _process(_delta):
	if following and can_drag:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - dragging_start_position)

func _on_TitleBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = not following
			dragging_start_position = get_local_mouse_position()

func is_window_size_max() -> bool:
	return OS.get_window_size().is_equal_approx(OS.get_screen_size())

func _on_MinimizeButton_pressed():
	OS.set_window_minimized(true)

func _on_CloseButton_pressed():
	get_tree().quit()

func _on_TitleBar_mouse_entered():
	
	if not OS.window_borderless or is_window_size_max(): return
		
	resize_title_bar()
	can_drag = true
	$ShowWhenHover / HBoxContainer.add_constant_override("separation", 0)
	$ShowWhenHover.show()

func _on_TitleBar_mouse_exited():
	can_drag = false
	$ShowWhenHover.hide()

func resize_title_bar():
	var minimize_button = $ShowWhenHover / HBoxContainer / MinimizeButton
	var close_button = $ShowWhenHover / HBoxContainer / CloseButton
	
	var less_than_720 = OS.get_window_size().y < 720
	
	self.rect_size.y = 60 if less_than_720 else 37
	minimize_button.rect_size.x = 60 if less_than_720 else 30
	close_button.rect_size.x = 60 if less_than_720 else 30

	self.rect_size.x = 1280
