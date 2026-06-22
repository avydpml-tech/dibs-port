extends Interactable

export (Resource) var ammo_PackedScene
export (int) var light_energy_amount = 2

func _ready():
	add_to_group("CanBeShot")
	$Light2D.energy = light_energy_amount
		
	if activated:
		item_activated()

func shot(_dmg):
	activated = true
	ItemManager.save_item(self.save())
	call_deferred("drop_ammo")
	call_deferred("free")


func drop_ammo():
	var ammo_inst = ammo_PackedScene.instance()
	ammo_inst.is_temporary = true
	
	print(get_owner())
	get_owner().add_child(ammo_inst, true)
	ammo_inst.set_owner(get_owner())
	ammo_inst.global_position = $dropAmmoPos.global_position


func item_activated():
	call_deferred("free")
