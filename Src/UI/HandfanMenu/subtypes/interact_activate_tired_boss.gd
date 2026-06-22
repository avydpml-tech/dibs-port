extends InteractOptionBtn

signal tired_boss_activated

func _ready():
	_connect_signals()

func _connect_signals():
	for i in get_tree().get_nodes_in_group(signal_target):
		self.connect("tired_boss_activated", i, "_tired_boss_activate")

func _on_InteractOptionBtn_pressed():
	if should_hide_when_pressed:
		emit_signal("tired_boss_activated")