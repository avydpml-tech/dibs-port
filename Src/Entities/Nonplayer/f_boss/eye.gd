extends Sprite


	




	
	
	
	

	

func look(pos) -> void :
	match pos:
		"left":
			position.x = - 20
		"right":
			position.x = 20
		_: pass