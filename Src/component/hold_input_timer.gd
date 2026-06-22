extends Timer

signal input_pressed
signal input_released

export (String) var action_event

func _input(event):
	if event.is_action_pressed(action_event):
		pressed_input()

	if event.is_action_released(action_event):
		released_input()


func pressed_input():
	emit_signal("input_pressed")
	paused = false
	start()


func released_input():
	emit_signal("input_released")
	paused = true