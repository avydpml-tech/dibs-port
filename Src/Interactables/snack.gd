extends Interactable

export (float) var light_energy = 0.0


export (Resource) var ammo_img_1_near_empty


export (bool) var is_temporary = false
var unique_id

func _ready():
	if is_temporary:
		var percent = randf()
		rotation_degrees += 30 if percent > 0.5 else - 50

	add_to_group("Interactable")
	_hide_silhouette()
	$Light2D.energy = light_energy
	$Label.visible = false


func _enter_tree():
	
	remove_from_group("ItemPersist")
	unique_id = get_name()


func interacted():
	activated = true
	give_snack_to_player()
	SaveManager.save_achievements()
	call_deferred("free")


func give_snack_to_player():
	Achievements.snack_found()



func item_activated():
	call_deferred("free")







var player = null
func _player_entered():
	_set_player()
	_show_silhouette()
	player_entered = true
	

func _set_player():
	if player != null: return
	for p in get_tree().get_nodes_in_group("Player"):
		player = p


func _show_silhouette():
	$"Biorganic device copie 3".show()
	

func _hide_silhouette():
	$"Biorganic device copie 3".hide()
	pass






func save():
	var save_dict = {
		"unique_id": get_name(), 
		"filename": get_filename(), 
		"pos_x": global_position.x, 
		"pos_y": global_position.y, 
		"rotation_degrees": rotation_degrees, 
		"parent_path": get_parent().get_path(), 
		"owner_path": get_owner().get_filename(), 
		"activated": activated, 
		"is_temporary": is_temporary, 
	}
	return save_dict









	
	
