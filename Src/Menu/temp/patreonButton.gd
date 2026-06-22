extends Button

export (float, 1) var modulate_hover = 1
export (float, 1) var modulate_default = 0.5


func _ready():
	modulate = Color(1, 1, 1, modulate_default)

func _on_moxieButton_mouse_entered():
	modulate = Color(1.73, 1.17, 1, modulate_hover)

func _on_moxieButton_mouse_exited():
	modulate = Color(1, 1, 1, modulate_default)

func _on_moxieButton_pressed():
	OS.shell_open("https://www.patreon.com/user?u=34316216")
