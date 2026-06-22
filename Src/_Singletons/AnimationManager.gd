extends Node






\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
"\n# ----- Generic Editing of Keyframe -----\n\nvar animation_name = $AnimationPlayer.current_animation # or some other name\nvar animation = $AnimationPlayer.get_animation(animation_name)\n\nvar track_name = 'Spatial:translation'\nvar track = animation.find_track(track_name) # returns idx of track\n\nAnimation.add_track(0)\nAnimation.length = 0.8\nAnimation.track_insert_key_frame(0, 0.5, 3) # track idx, time, key \n\nvar last_key = animation.track_get_key_count(track) - 1\n\nanimation.track_set_key_value(track, last_key, original_position)\n"










func add_keyframe(
	animation_player, 
	animation_name = "", 
	track_name = "", 
	time = 0, 
	variant = null, 
	easing = 1
	):

	if animation_name == "":
		animation_name = animation_player.current_animation
		if animation_name == "": return

	var animation = animation_player.get_animation(animation_name)
	var track_idx = animation.find_track(track_name)

	if track_idx == - 1:
		var temp_idx = animation.add_track(0)
		
		animation.track_set_path(temp_idx, track_name)
		return

	animation.track_insert_key(track_idx, time, variant)
	var frame_idx = animation.track_find_key(track_idx, time)
	animation.track_set_key_transition(track_idx, frame_idx, easing)




func set_animation_player_keyframe( var animation_player):
	
	var animation_name = $AnimationPlayer.current_animation
	var animation = $AnimationPlayer.get_animation("mouse_exited")
	
	var property_name = "circle:scale"
	var track = animation.find_track(property_name)
	var last_keyframe = animation.track_get_key_count(track) - 1
	
	
	animation.track_set_key_value(track, 0, $circle.scale)
	

func set_keyframe_length(
	var animation_player, 
	animation_name = "", 
	track_name = "", 
	frame_idx = 0, 
	time = 0
	):
	
	var animation = animation_player.get_animation(animation_name)
	var track_idx = animation.find_track(track_name)
	
	
	if time > animation.length:
		animation.length = time

	animation.track_set_key_time(track_idx, frame_idx, time)
