extends Interactable


export (String) var interacts_to = ""
export (String) var unique_id = ""




func _ready():
	if unique_id != "":
		add_to_group(unique_id)
	

func trigger_activated():
	for obj in get_tree().get_nodes_in_group(interacts_to):
		if obj != null:
			obj._interacted_by_obj()

func _interacted_by_obj():
	activated = true

func _interacted_by_EventManager(variant):
	_interacted_by_obj()

func _on_Area2D_body_entered(body):
	if body.get_name() == "playerChar" and activated:
		activated = false
		trigger_activated()
	

