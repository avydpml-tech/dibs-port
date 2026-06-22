extends Interactable

export (String) var tape_name = "UNNAMED TAPE"
export (float) var light_energy = 0.0
export (bool) var disabled = false

var unique_id


func _enter_tree():
	unique_id = get_name()
	add_to_group("Interactable")
	add_to_group("Tape")


func _ready():
	if tape_name in Achievements.collected_tapes:
		call_deferred("free")

	_hide_silhouette()
	$Light2D.energy = light_energy


func interacted():
	if disabled:
		return

	activated = true
	Achievements.tape_found(tape_name)
	Globals.get_player().tape_found()
	SaveManager.save_achievements()
	call_deferred("free")

func enable():
	disabled = false
	show()


func item_activated():
	pass


func _show_silhouette():
	$"Biorganic device copie 3".show()
	pass


func _hide_silhouette():
	$"Biorganic device copie 3".hide()
	pass




func append_to_EventManager():
	var name = get_name()
	var owner = get_owner().get_filename()

	var target_scene = "res://Src/1_World/1_zones/MallZones/Stage_01_b-CinemaRoom.tscn"
	var interacts_to = "UNASSIGNED"

	EventManager.link_to_target(target_scene, interacts_to, tape_name)
	EventManager.log_relationship(owner, name, interacts_to)





















func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
