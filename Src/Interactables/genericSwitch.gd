extends Interactable



export (String) var target_scene = "UNASSIGNED"
export (Array, String) var target_scenes = []
export (String) var interacts_to = "UNASSIGNED"
export (bool) var is_reflip_allowed = false
export (bool) var is_wolf_in_mall = false

func _ready():
	$"Enter 3".hide()
	$Area2D.show_on_top = true
	$"Enter 1".visible = true

	if target_scene == "SELF":
		target_scene = get_owner().get_filename()


func interacted():
	$"Enter 3/AnimationPlayer".play("clicked")
	$"Enter 1".visible = false
	
	if not activated:
		$switch.play()
		activated = true
		append_to_EventManager()
		EventManager.apply_properties_to_target(get_owner().get_filename())

	if is_wolf_in_mall:
		Achievements.is_allow_wolf_in_mall = true



func _interacted_by_obj():
	print(self.get_name(), " does not have its own function.")


func append_to_EventManager():
	var name = get_name()
	var owner = get_owner().get_filename()
	var switch_state = activated

	EventManager.link_to_target(target_scene, interacts_to, switch_state)
	EventManager.log_relationship(owner, name, interacts_to)


func _show_silhouette(): $"Enter 3".show()


func _hide_silhouette(): $"Enter 3".hide()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) and player_entered:
		interacted()


func _on_Area2D_mouse_entered():
	
	pass
