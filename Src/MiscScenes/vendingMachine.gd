extends Interactable


export (bool) var is_empty = false
export (PackedScene) var snack_instance


func _ready():
	add_to_group("Interactable")
	if (is_empty or not Achievements.is_snack_empty()) or Achievements.is_vending_machine_empty:
		$Art / Snack.hide()
		$Art / smallLight.hide()
		$Art / VendingMachineGlow.hide()
		return

	if Achievements.is_vending_machine_empty and Achievements.is_snack_empty():
		call_deferred("_spawn_snack")


func interacted():
	if not Achievements.is_vending_machine_empty and not is_empty:
		$Art / AnimationPlayer.play("drop_snack")
		is_empty = true
		Achievements.is_vending_machine_empty = true


func _spawn_snack():
	var snack = snack_instance.instance()
	get_owner().add_child(snack)
	snack.global_position = $snackSpawn.global_position


