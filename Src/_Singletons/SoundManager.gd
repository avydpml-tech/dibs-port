






extends Node2D

var sound_list: Dictionary = {}
var music_list: Dictionary = {}

var music_inst: AudioStreamPlayer
var bsfx_inst: AudioStreamPlayer


func _ready():
	music_inst = AudioStreamPlayer.new()
	bsfx_inst = AudioStreamPlayer.new()
	music_inst.bus = "Music"
	bsfx_inst.bus = "SFX"
	
	add_child(music_inst)
	add_child(bsfx_inst)
	
	instance_sound_list()
	instance_music_list()
	

func instance_sound_list():
	sound_list = {
		"metal_floor_break": "res://Assets/1_Audio/sfx/_environment/metal_floor_break.ogg", 
		"door": "res://Assets/1_Audio/sfx/_environment/door/door_spedup.ogg", 
		"enemy_hit": "res://Assets/1_Audio/sfx/weapon_sounds/1_final/hit/enemy_hit.ogg", 
		"unsatisfying_hit": "res://Assets/1_Audio/sfx/weapon_sounds/1_final/hit/unsatisfying_hit.ogg", 
	}

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






func play_music(title: String, time_start: float = 0):
	_play_sound(title, time_start, music_inst, 0, "music")


func set_music_effect(effect: String):
	match effect:
		"reverb": _set_reverb("Music", true)
		"none": _set_reverb("Music", false)


func stop_music():
	music_inst.stop()


func play_bsfx( var title: String, var time_start: float = 0, var volume: float = 0):
	_play_sound(title, time_start, bsfx_inst, volume, "sound")


func _play_sound(title, time_start, audio_node = null, volume: float = 0, type_of_sound = ""):
	

	var list
	match type_of_sound:
		"music": list = music_list
		"sound": list = sound_list

	if not list.has(title):
		_strip_and_add_to_list(title, type_of_sound)
		
	var new_stream = load(list.get(title))

	if audio_node.stream != new_stream:
		audio_node.stream = new_stream
	
	audio_node.volume_db = volume
	audio_node.play(time_start)
	yield(audio_node, "finished")
	audio_node.volume_db = 0



	
func just_play_sound(new_stream):
	if bsfx_inst.stream != new_stream:
		bsfx_inst.stream = new_stream
	
	bsfx_inst.play()
	yield(bsfx_inst, "finished")
	bsfx_inst.volume_db = 0


func play_smart_audio(title, volume: int = 0):
	var audio_stream_inst = AudioStreamPlayer.new()
		
	var file_path = sound_list.get(title)
	var new_stream = load(file_path)

	if audio_stream_inst.stream != new_stream:
		audio_stream_inst.stream = new_stream

	audio_stream_inst.volume_db = volume
	audio_stream_inst.play()
	audio_stream_inst.set_bus("SFX")
	get_parent().add_child(audio_stream_inst)

	yield(audio_stream_inst, "finished")
	audio_stream_inst.call_deferred("free")

	








func _strip_and_add_to_list(path, type_of_sound):
	
	var path_array_without_file_extension = path.split(".")[0]
	var path_array_directory = path_array_without_file_extension.split("/")
	var sound_filename = path_array_directory[path_array_directory.size() - 1]

	var key = sound_filename
	var value = path

	match type_of_sound:
		"sound": sound_list[key] = value
		"music": music_list[key] = value


func is_music_playing(music_title) -> bool:
	if music_inst.stream == null:
		return false

	for key in music_list:
		if not music_inst.stream.resource_path == music_list[key]:
			return true

	return false





func _enable_master_volume():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 0)
	
func _disable_master_volume():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), - 1000)

func _set_reverb(audio_bus: String, boolean):
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index(audio_bus), 0, boolean)
