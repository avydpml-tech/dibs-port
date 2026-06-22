extends Interactable

export var magazine_size = 1
export (float) var light_energy = 0.0
export (int) var ammo_amount = 9


export (Resource) var ammo_img_4_full
export (Resource) var ammo_img_3_quarter
export (Resource) var ammo_img_2_half
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
	_update_ammo_sprite()
	$Label.visible = false

func _enter_tree():
	unique_id = get_name()

func interacted():
	activated = true
	
	
	
	
	if not player.is_magazine_arr_full(magazine_size):
		player.add_mag(ammo_amount)
		if not is_temporary:
			ItemManager.save_item(self.save())
		call_deferred("free")
		
	
	elif not player.is_ammo_in_magazine_arr_bigger(ammo_amount):
		player.replace_least_ammo_in_magazine_arr(ammo_amount)
		if not is_temporary:
			ItemManager.save_item(self.save())
		call_deferred("free")
	
	




func _update_ammo_sprite():
	match ammo_amount:
		6, 7: $AmmoSprite.set_texture(ammo_img_3_quarter)
		5, 4: $AmmoSprite.set_texture(ammo_img_2_half)
		3, 2, 1: $AmmoSprite.set_texture(ammo_img_1_near_empty)
		_: pass


func item_activated():
	call_deferred("free")







var player = null
func _player_entered():
	_set_player()

	
	if not player.is_magazine_arr_full(magazine_size)\
	or not player.is_ammo_in_magazine_arr_bigger(ammo_amount):
		_show_silhouette()
	player_entered = true
	
func _set_player():
	if player != null: return
	for p in get_tree().get_nodes_in_group("Player"):
		player = p

func _show_silhouette():
	$AmmoSpriteOutline.show()
	
func _hide_silhouette():
	$AmmoSpriteOutline.hide()
	pass

func save_ammo():
	var save_dict = {
		"unique_id": get_name(), 
		"filename": get_filename(), 
		"pos_x": global_position.x, 
		"pos_y": global_position.y, 
		"rotation_degrees": rotation_degrees, 
		"parent_path": get_parent().get_path(), 
		"owner_path": get_owner().get_filename(), 
		"ammo_amount": ammo_amount, 
		"is_temporary": is_temporary, 
	}
	return save_dict





















func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass