extends Stage

var is_player_on_newspaper: bool = false
func _input(event):
	if event.is_action_pressed("ui_down") and is_player_on_newspaper:
		news_label()

func news_label():
	$Newspapers / AnimationPlayer.play("press_up")

func _on_newspaperEnter_body_entered(body: Node):
	is_player_on_newspaper = true
	pass


func _on_newspaperEnter_body_exited(body: Node):
	is_player_on_newspaper = false
	pass
