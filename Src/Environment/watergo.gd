extends Area2D

export (int) var player_slow_movement = 250
export (int) var Nonplayer_slow_movement = 250


var bodies_in_the_water_list = []

func _ready():
	set_process(false)

func _process(delta):
	for body in bodies_in_the_water_list:
		if body != null:
			if body.get_name() == "playerChar":
				body._movement_slow_speed(player_slow_movement)
				body._lower_jump( - 300)
				body._set_floor_type("wet")
			
			
	
func show_thing_on_top_scene():
	if get_parent() != get_owner():
		get_parent().show_on_top = true
	else:
		show_on_top = true

func _on_watergoo_body_entered(body):

	if body.get_name() == "playerChar":
		bodies_in_the_water_list.append(body)
		$AudioStreamPlayer2D.play()
		set_process(true)
	elif body.get_class() == "Nonplayer":
		if not bodies_in_the_water_list.has(body):
			$AudioStreamPlayer2D.play()
			bodies_in_the_water_list.append(body)


func _on_watergoo_body_exited(body):
	if body.get_name() == "playerChar":
		$AudioStreamPlayer2D.play()
		bodies_in_the_water_list.erase(body)
		set_process(false)
		body._movement_default_speed()
		body._reset_jump_height_timer(0.3)
		body._set_floor_type("dry")
	
	elif body.get_class() == "Nonplayer":
		$AudioStreamPlayer2D.play()
		bodies_in_the_water_list.erase(body)
