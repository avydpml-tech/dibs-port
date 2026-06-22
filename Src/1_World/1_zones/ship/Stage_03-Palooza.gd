extends Stage

func _on_disableBlaster_body_entered(body: Node):
	if body.get_name() == "playerChar":
		Globals.get_player().disable_blaster()

func _on_enableBlaster_body_entered(body: Node):
	if body.get_name() == "playerChar":
		Globals.get_player().enable_blaster()
