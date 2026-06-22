extends InteractOptionBtn

signal interacted

func _ready():
	_connect_signals()


func _connect_signals():
	for i in get_tree().get_nodes_in_group(signal_target):
		self.connect("interacted", i, "_interacted")

func _on_InteractOptionBtn_pressed():
	emit_signal("interacted")