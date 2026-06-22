extends TextureButton
class_name InteractOptionBtn

export (bool) var should_hide_when_pressed = true
export (String) var signal_target = ""

signal option_selected

func _ready():
	rect_min_size = Vector2(50, 50)

func _on_InteractOptionBtn_mouse_exited():
	release_focus()

func _on_InteractOptionBtn_mouse_entered():
	grab_focus()

func _on_InteractOptionBtn_pressed():
	if should_hide_when_pressed:
		emit_signal("option_selected")
