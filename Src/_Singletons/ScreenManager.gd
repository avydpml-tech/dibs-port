extends CanvasLayer

onready var fade_anim_player = $Control / ColorRect / AnimationPlayer


signal fade_in_finished
signal fade_finished


func fade(fade_in_length = 1.0, fade_out_length = 1.0, fade_buffer = 0.1):
	fade_in(fade_in_length)
	yield(fade_anim_player, "animation_finished")
	emit_signal("fade_in_finished")
	fade_out(fade_out_length, fade_buffer)


func fade_in( var fade_length = 1.0):
	set_fade_length(fade_anim_player, "fade_in", fade_length)
	fade_anim_player.play("fade_in")


func fade_out( var fade_out_length: float = 1, var fade_buffer = 0.1):

	
	AnimationManager.set_keyframe_length(fade_anim_player, "fade_out", ".:color", 1, fade_buffer)

	
	AnimationManager.set_keyframe_length(fade_anim_player, "fade_out", ".:color", 2, fade_out_length + fade_buffer)

	fade_anim_player.play("fade_out")


func set_fade_length(animation_player, animation_name, fade_length):
	AnimationManager.set_keyframe_length(animation_player, animation_name, ".:color", 1, fade_length)
	animation_player.get_animation("fade_in").length = fade_length


func set_fade_timeout_signal(body, method):
	self.connect("fade_in_finished", body, method)


func slow_fade(speed = 0.1):
	fade_anim_player.set_speed_scale(speed)
	

func normal_speed_fade():
	fade_anim_player.set_speed_scale(1)
