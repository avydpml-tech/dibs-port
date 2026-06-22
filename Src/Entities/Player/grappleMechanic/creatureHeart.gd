extends KinematicBody2D

signal creature_dead

var creature

func _ready():
	
	if not is_connected("creature_dead", get_parent(), "_creature_dead"):
		connect("creature_dead", get_parent(), "_creature_dead")
	modulate = "ffffff"

	if get_parent().mon_name == "boss" or get_parent().mon_name == "":
		queue_free()
		return

	call_deferred("set_creature")

	if creature != null:
		call_deferred("shrink_heart_based_on_hp")

	

func set_creature():

	$Label.hide()
	creature = get_parent().entity_inst
	
	if get_parent().mon_name == "f_koubold":
		queue_free()
		$Label.show()
	
func damage(hit_points):
	$AnimationPlayer.play("On Hit")
	SoundManager.play_bsfx("enemy_hit")
	chase_faster_if_low_hp()
	shrink_heart_based_on_hp()

	if not SettingsManager.is_bored_mode:
		Globals.get_player().stamina += 5

	creature.take_damage(hit_points, Vector2(0, 0), 0)
	if (creature.current_health <= 0):
		emit_signal("creature_dead")


		
func shrink_heart_based_on_hp():
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	var new_scale = creature.max_health / 10.0
	self.scale = Vector2(new_scale, new_scale)



		
func chase_faster_if_low_hp():
	for tenticon in get_tree().get_nodes_in_group("Tenticons"):
		
		if creature.current_health / creature.max_health < 0.15:
			tenticon.SPEED += 50
			tenticon.curr_speed += 50
