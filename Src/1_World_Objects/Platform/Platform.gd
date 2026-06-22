extends Node2D


export (int) var end_position = 0

func _ready():
	pass

var bodies_area = []

func interacted():
	pass

func rise_platform():
	pass


func rise_value_changed(new_value):
	$AnimationPlayer.play("show_lights")
	$AnimationPlayer.play_backwards("show_lights")
	

func _on_Area2D_body_entered(body):
	if body.get_class() == "Nonplayer":
		if not bodies_area.has(body):
			bodies_area.append(body)


func _on_Area2D2_body_exited(body):
	if body.get_class() == "Nonplayer":
		bodies_area.erase(body)
		

	
