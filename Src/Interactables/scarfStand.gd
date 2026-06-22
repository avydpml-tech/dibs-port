extends Interactable


export (String) var unique_id = ""
var play_sound: bool = false


func _ready():
	get_node("scarf/scarfHighlighted").hide()
	$Area2D.show_on_top = true

	call_deferred("_interacted_by_obj")
	
func _enter_tree():
	if unique_id != "":
		add_to_group(unique_id)


func interacted():
	$scarf.hide()

	if activated: return

	Achievements.scarf_found()
	activated = true
	ItemManager.save_item(self.save())


func _interacted_by_obj():
	if activated:
		$scarf.hide()
	




func _interacted_by_EventManager(variant):
	pass


func _show_silhouette():
	if not activated:
		$scarf / scarfHighlighted.show()


func _hide_silhouette():
	$scarf / scarfHighlighted.hide()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) and player_entered:
		interacted()


func _on_Area2D_mouse_entered():
	pass
