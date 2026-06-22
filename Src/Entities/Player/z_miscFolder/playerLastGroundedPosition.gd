extends Position2D

var player

func _ready():
	add_to_group("playerLastGroundedPosition")


func _process(delta):
	if player == null: return


	if player.is_on_floor():
		global_position = player.global_position