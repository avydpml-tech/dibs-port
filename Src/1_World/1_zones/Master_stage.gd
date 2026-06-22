extends Node2D

class_name Stage

var tilemap
export (String) var day_or_night = "bright"
export (String, "NULL", "m_bump_in_the_night", "m_mall_song", "m_apprehension", "m_space_jazz", "m_clair_de_lune", "m_cafe_jazz", "m_gymnopedie_1") var stage_music = null
export (bool) var start_event_manager = true
export (bool) var music_off = false

signal new_time

func _generic_ready():
	PosManager.place_player()
	emit_signal("new_time", day_or_night)
	ItemManager.generic_ready()
	ItemManager.load_ammo_in_this_scene(self)
	EntityManager.generic_ready()

	if music_off:
		SoundManager.stop_music()
	elif not stage_music in [null, "NULL"] and not music_off:
		SoundManager.play_music(stage_music)
		if stage_music == "m_mall_song":
			SoundManager.set_music_effect("reverb")

	
	
	
	
	if start_event_manager:
		EventManager.apply_properties_to_target(get_filename())


func _ready():
	_generic_ready()
	

func _set_player_camera_limits(is_limits_on = true, left = 0, top = 0, right = 1000, bottom = 1000):
	var temp = Globals.get_player().get_node("playerCamera")

	temp.limit_left = left if is_limits_on else 10000000
	temp.limit_top = top if is_limits_on else 10000000
	temp.limit_right = right if is_limits_on else 10000000
	temp.limit_bottom = bottom if is_limits_on else 10000000
	

func _enter_tree():
	pass

func _exit_tree():
	pass

func _process(_delta):
	pass
	


func change_lighting(new_lighting):
	emit_signal("new_time", new_lighting)
