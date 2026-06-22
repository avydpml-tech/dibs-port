extends Node

export (String, "ship", "idle", "elevator", "bored") var current_ending

func _ready():

	if EndingsManager.current_ending != "":
		show_ending_node(EndingsManager.current_ending)
	else:
		show_ending_node(current_ending)

	current_ending = EndingsManager.current_ending

	$idle / AnimationPlayer.play("bored")
	$bored / AnimationPlayer.play("bored")
	
	if current_ending == "idle":
		check_idle_ending()


func _exit_tree():
	SoundManager.stop_music()


func show_ending_node(ending):
	for i in get_children():
		if i.get_name() != ending and i.get_name() != "Control":
			i.hide()
		else:
			i.show()


func play_jazz():
	if not EndingsManager.current_ending in ["idle", "bored"]: return
	SoundManager.play_music("m_space_jazz")


func check_idle_ending():
	$idle / Button.new_scene_path = Globals.get_current_level()
