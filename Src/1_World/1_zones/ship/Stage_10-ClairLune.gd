extends Stage

func _ready():
	_generic_ready()
	SoundManager.stop_music()
	print_debug("Stage_10-ClairLune: Ignore the font error. Godot's just being whiney. It doesn't affect gameplay.")
	
