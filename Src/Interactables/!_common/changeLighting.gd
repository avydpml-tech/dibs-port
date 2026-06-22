extends Area2D

export (String) var lighting = ""


func _on_changeLighting_body_entered(body):
	if Globals._is_player(body):
		get_owner().change_lighting(lighting)
