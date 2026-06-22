extends Stage

func _ready():
	
	
	
	_generic_ready()

	if Globals.get_player().coom_count >= 3:
		Globals.get_player().coom_count = 0

	pass
