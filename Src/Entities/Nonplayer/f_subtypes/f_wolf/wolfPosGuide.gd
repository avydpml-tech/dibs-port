extends Position2D

export (NodePath) var target_node_path
export (String, "idle", "stare_afar") var state_upon_enter

func _ready():
	set_as_destination_for_target_node()


func set_as_destination_for_target_node():
	if get_node(target_node_path) != null:
		get_node(target_node_path).go_to_destination(self)
		pass


func _on_Area2D_body_entered(body: Node):
	if body == get_node(target_node_path):
		
		body.at_destination()
		pass
	else:
		
		pass
	pass

func _on_Area2D_body_exited(body: Node):
	pass

