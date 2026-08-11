extends CanvasLayer

signal scene_changed()

var current_scene: String = ""

func _change_scene(path, fade_time = 0.2, hold_fade = 0, var delay = 0.1):
	# Безопасная версия без yield и анимации (для Android)
	current_scene = str(path)
	get_tree().change_scene(path)
	emit_signal("scene_changed")

func get_current_scene() -> String:
	return current_scene
