extends Sprite

export (float) var pos_x = null
export (float) var attack_pos_y_left = 0
export (float) var attack_pos_y_right = 0
export (float) var attack_pos_x_left = 0

onready var player = get_parent()



func _process(_delta):
	gun_reference()
	look_at(player.aim_pos_reference.global_position)
	

	match player.dir:
		"left":
			flip_v = true
			position.x = pos_x - attack_pos_x_left
		"right":
			flip_v = false
			position.x = - pos_x

	show() if player.player_state == "aim" else hide()
	
	


func gun_reference():
	match player.dir:
		"left": player.aim_pos_reference.position.y = - attack_pos_y_left
		"right": player.aim_pos_reference.position.y = attack_pos_y_right
