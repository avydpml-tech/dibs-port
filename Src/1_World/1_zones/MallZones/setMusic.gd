extends Node2D

export (String, "m_mall_song") var music = "m_mall_song"
var music_list = []

func instance_music_list():
	music_list = {
		"m_floating_cities": "res://Assets/1_Audio/music/m_floating_cities.ogg", 
		"m_bump_in_the_night": "res://Assets/1_Audio/music/m_bump_in_the_night.ogg", 
		"m_gymnopedie_1": "res://Assets/1_Audio/music/m_gymnopedie.ogg", 
		"m_clair_de_lune": "res://Assets/1_Audio/music/m_clair_de_lune.ogg", 
		"m_mall_song": "res://Assets/1_Audio/music/_To_Be_Replaced/Mall Music/m_mall_song.ogg", 
		"m_apprehension": "res://Assets/1_Audio/music/m_apprehension.ogg", 
		"m_space_jazz": "res://Assets/1_Audio/music/m_space_jazz.ogg", 
		"m_cafe_jazz": "res://Assets/1_Audio/music/m_cafe_jazz.ogg", 
	}


func _ready():
	instance_music_list()

	for i in get_children():
		if i is AudioStreamPlayer2D:
			if not OS.is_debug_build():
				i.stream = load(music_list["m_mall_song"])
			
			else:
				i.stream = load(music_list[music])
