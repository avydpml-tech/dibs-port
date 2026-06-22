extends CanvasLayer

signal scene_changed()

onready var animation_player = $AnimationPlayer
onready var black = $Control / black

var current_scene: String = ""

func _change_scene(path, fade_time = 0.2, hold_fade = 0, var delay = 0.1):
	set_fade_length(fade_time)

	

	$Control.show()
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("Fade")
	yield(animation_player, "animation_finished")
	get_tree().change_scene(path)
	yield(get_tree().create_timer(hold_fade), "timeout")
	animation_player.play_backwards("Fade")
	yield(animation_player, "animation_finished")
	$Control.hide()

	current_scene = path
	
	emit_signal("scene_changed")



func set_fade_length(fade_time):
	var animation = animation_player.get_animation("Fade")
	var track_idx = animation.find_track("Control/black:color")
	animation.length = fade_time
	animation.track_set_key_time(track_idx, 1, fade_time)


func get_current_scene() -> String:
	return current_scene
