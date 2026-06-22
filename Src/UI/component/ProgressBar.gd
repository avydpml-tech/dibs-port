extends TextureProgress



signal timeout
export (float) var held_input_time = 2
onready var hold_timer = $HoldInputTimer

func _ready():
				hold_timer.wait_time = held_input_time

				hold_timer.connect("timeout", self, "emit_timeout")
				hold_timer.connect("input_pressed", self, "show")
				hold_timer.connect("input_released", self, "hide")
				Globals.get_player().connect("player_state_changed", self, "update_visibility")

				hide()


func _process(delta):
				value = (held_input_time - hold_timer.time_left) / held_input_time * 100


func emit_timeout():
				if Globals.get_player().player_state == "idle":
								emit_signal("timeout")
				hide()


func update_visibility():
				match Globals.get_player().player_state:
								"idle": pass
								_: hide()