extends InteractOptionBtn


func _on_InteractOptionBtn_pressed():
	if should_hide_when_pressed:
		PosManager.set_start_location("computer")
		emit_signal("option_selected")

		