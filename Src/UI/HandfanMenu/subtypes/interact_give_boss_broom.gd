extends InteractOptionBtn

var boss

func _ready():
	
	for i in get_tree().get_nodes_in_group(signal_target):
		boss = i


func _on_InteractOptionBtn_pressed():
	boss.emit_trigger("given_broom")
