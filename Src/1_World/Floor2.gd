extends Node2D

export (int) var end_position = null
	
var rise_value = 0
var start_position = Vector2(0, 0)

func _ready():
	start_position = get_global_position()

func _process(delta):

	if start_position.y <= position.y or global_position.y <= end_position:
		rise_value = 0

	global_position.y -= delta * rise_value
	
		


func _on_Area2D_body_entered(body):
	if Globals._is_player(body):
		rise_value = 200
		global_position.y -= 10
		


func _on_Area2D_body_exited(body):
	if Globals._is_player(body):
		rise_value = - 300
		global_position.y += 10
				
