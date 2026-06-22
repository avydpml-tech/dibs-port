extends Interactable

export var clothe_health = 10
export (float) var light_energy = 0.0

func _ready():
	add_to_group("Interactable")
	if SettingsManager.is_frisky:
		hide()
	_hide_silhouette()
	$Light2D.energy = light_energy


func interacted():
	if SettingsManager.is_frisky:
		return
	activated = true

	
	for p in get_tree().get_nodes_in_group("Player"):
		if not p._is_health_full():
			p._add_health(clothe_health)
			ItemManager.save_item(self.save())
			call_deferred("free")


func item_activated():
	call_deferred("free")

func _show_silhouette():
	$"Biorganic device copie 3".show()
	pass
	
func _hide_silhouette():
	$"Biorganic device copie 3".hide()
	pass




















func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
