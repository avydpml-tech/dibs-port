extends Area2D








func _ready():
	pass

func _on_meleeRange_body_entered(_body):
	for body in get_overlapping_bodies():
		if body.get_class() == "Nonplayer":
			body.knock_back(500, get_owner().global_position)
		pass




