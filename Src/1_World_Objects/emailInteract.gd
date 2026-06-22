extends Node2D

var new_dialog
var is_player_nearby = false
var is_interacted = false

func _input(event):
	if (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_scroll_down")) and is_player_nearby:
		if new_dialog == null or not is_instance_valid(new_dialog):
			new_dialog = Dialogic.start("MoxEmail")
			add_child(new_dialog)

			if not is_interacted:
				$infobeep.play()
			is_interacted = true


func _on_playerEntered_body_entered(body: Node):
	if Globals._is_player(body):
		is_player_nearby = true


func _on_playerEntered_body_exited(body: Node):
	is_player_nearby = false


func _on_emailInteract_body_exited(body: Node):
	return
	if not new_dialog == null and is_instance_valid(new_dialog):
		call_deferred("remove_child", new_dialog)