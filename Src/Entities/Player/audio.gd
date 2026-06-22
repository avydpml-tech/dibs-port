extends Node2D











onready var parent = get_parent()


func _ready():
	
	
	
	
	_preload_sound_effects()
	pass





onready var step_node = $step
onready var floor_type: String = parent.floor_type
var step_list = []
var rand_step: int = 0

var preloaded_footstep_dry = []
var preloaded_footstep_wet = []


func _play_audio_footstep():
	_handle_footstep_sounds()
	step_node.play()
	

func _handle_footstep_sounds():
	
	step_node.stream = step_list[rand_step]
	_increment_rand_step()


func _increment_rand_step():
	rand_step = rand_step + 1 if (rand_step < 3) else 0


func _preload_sound_effects():
	var step_dry = "res://Assets/1_Audio/sfx/footsteps/footsteps/step"
	var step_wet = "res://Assets/1_Audio/sfx/footsteps/footsteps/sploosh"

	for i in range(1, 5):
		
		var audio = step_dry + str(i) + ".ogg"
		preloaded_footstep_dry.append(load(audio))

		
		audio = step_wet + str(i) + ".ogg"
		preloaded_footstep_wet.append(load(audio))

	
	step_list = preloaded_footstep_dry


	
func _set_audio_floor_type():
	floor_type = parent.floor_type
	match floor_type:
		"wet": step_list = preloaded_footstep_wet
		"dry": step_list = preloaded_footstep_dry
	








onready var shlick = $shlick
onready var voice_node = $voice2
var voice_folder_path = "res://Assets/1_Audio/sfx/smex/Moan/Curated/voice/"
var oral_folder_path = "res://Assets/1_Audio/sfx/smex/Moan/Curated/oral/"










var voice_list = [
	load("res://Assets/1_Audio/sfx/smex/Moan/Curated/voice/SWFMoan274.ogg"), 
	load("res://Assets/1_Audio/sfx/smex/Moan/Curated/voice/SWFMoan276.ogg"), 
]
var oral_list = [
	
	load("res://Assets/1_Audio/sfx/smex/Moan/Curated/oral/SWFMoan269.ogg"), 
	load("res://Assets/1_Audio/sfx/smex/Moan/Curated/oral/SWFMoan270.ogg"), 
]




var voice_index: int = 0
var oral_voice_index: int = 0
var random = RandomNumberGenerator.new()

func play_voice():
	if voice_node.playing: return

	random.randomize()
	var rand_index = random.randi_range(1, len(voice_list) - 1)
	if rand_index == voice_index:
		if rand_index <= 0:
			rand_index += 1
		else:
			rand_index -= 1
	voice_index = rand_index

	var index = clamp(rand_index, 0, len(voice_list) - 1)
	
	voice_node.stream = voice_list[index]
	voice_node.play()
	
func play_oral_voice():
	if voice_node.playing: return

	random.randomize()
	var rand_index = random.randi_range(1, len(oral_list) - 1)
	if rand_index == oral_voice_index:
		if rand_index == 0:
			rand_index += 1
		else:
			rand_index -= 1
	oral_voice_index = rand_index

	if len(oral_list) == 1:
		rand_index = 0

	voice_node.stream = oral_list[rand_index]
	voice_node.play()
	

func _play_shlick_sounds():
	pass

func _play_coom_sounds():
	pass

func _handle_smexy_sounds():
	pass

































func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(false, true)

	while true:
		var file = dir.get_next()
		if file == "":
			break
		if not file.ends_with(".import"):
			files.append(file)
	
	dir.list_dir_end()
	return files

func dir_contents(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
