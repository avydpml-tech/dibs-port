extends Node2D

export (Resource) var clothes
export (NodePath)onready var wolf_inst = get_node(wolf_inst)

onready var start_scarf_offer_timer: Timer = $startScarfOfferTimer
onready var shiver_timer: Timer = $startShiverTimer
onready var smp = $StateMachinePlayer

var is_shown_tape: bool = false
var is_already_waved: bool = false
var is_player_grappled: bool = false
var is_hug: bool = false
var current_state: String = ""


func connect_signals():
	var player = Globals.get_player()
	if not player.is_connected("player_grappled", self, "_player_grappled"):
		player.connect("player_grappled", self, "_player_grappled")

	if not player.is_connected("player_grapple_freed", self, "_player_grapple_freed"):
		player.connect("player_grapple_freed", self, "_player_grapple_freed")

	if not wolf_inst.is_connected("wolf_walk_finished", self, "_wolf_walk_finished"):
		wolf_inst.connect("wolf_walk_finished", self, "_wolf_walk_finished")


func _ready():
	if not Achievements.is_mox_meetup_ready():
		call_deferred("free")
		return

	if Achievements.is_meetup_quest_complete:
		$scarf.show()
		$Broom.hide()

	wolf_inst.hide()
	wolf_inst.disable_interact()
	
	$kouboldMeetup / AnimationPlayer.play("kay_eat")
	$scarf / AnimationPlayer.play("kay_eat")

	Globals.connect("walk_area_entered", self, "_stop_miniquest_hug")


func _input(event):
	if event.is_action_pressed("ui_right_mouse"):
		$aimKoubsWoof / CollisionShape2D.disabled = false
	elif event.is_action_released("ui_right_mouse"):
		$aimKoubsWoof / CollisionShape2D.disabled = true


	if (event.is_action_pressed("ui_interact")) and Globals.get_player().player_state in ["idle", "run"]:
		if Globals.get_player() in $playerInteractArea.get_overlapping_bodies():
			interacted()

	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		_stop_miniquest_hug()


func _process(delta):
	
	
	
	if is_hug and SettingsManager.is_bored_mode:
		Globals.add_stamina(0.3)







func set_StateMachinePlayer_parameters():
	smp.set_param("is_hug", is_hug)


func _on_StateMachinePlayer_transited(from, to):

	current_state = to

	
	match to:
		
		
		"Eat":
			$kouboldMeetup / AnimationPlayer.play("kay_eat")
			$scarf / AnimationPlayer.play("kay_eat")
			shiver_timer.start()

		"Shiver":
			$kouboldMeetup / AnimationPlayer.play("kay_shiver")

		"Woof_Scarf_Offer":
			$kouboldMeetup / AnimationPlayer.play("woof_scooch_offer")

		"Woof_Scarf_Offer_Loop":
			$kouboldMeetup / AnimationPlayer.play("woof_scooch_offer_loop")

		"Woof_sit":
			
			pass

		"Hug":
			$kayHugTimer.start()
			var player = Globals.get_player()
			player.call_deferred("disable_mox")
			player.position.x = $moxHugPosition.global_position.x
			player.dir = "left"

			$kouboldMeetup / AnimationPlayer.play("kay_hug_clothed")
			$scarf / AnimationPlayer.play("kay_hug_clothed")

		"Hug_Return":
			$kouboldMeetup / AnimationPlayer.play("kay_calm_hug_clothed")
			$scarf / AnimationPlayer.play("kay_calm_hug_clothed")

		"Wave":
			$kouboldMeetup / AnimationPlayer.play("kay_hi")
			$scarf / AnimationPlayer.play("kay_hi")

		"Give_Clothe":
			$kouboldMeetup / AnimationPlayer.play("kay_give_clothes")
			$scarf / AnimationPlayer.play("kay_give_clothes")

		"Protect":
			connect_signals()
			$CanvasLayer / AnimationPlayer.play("alert")
			$kouboldMeetup / AnimationPlayer.play("kay_alert")
			$scarf / AnimationPlayer.play("kay_alert")
			aggrevate_wolf()


	
	match from:
		"Eat":
			shiver_timer.stop()

		"Hug":
			if to == "Eat":
				Globals.get_player().enable_mox()

		"Hug_Return":
			Globals.get_player().enable_mox()

		"Protect":
			wolf_inst.hide()
			wolf_inst.disable_interact()



func _on_StateMachinePlayer_updated(state, delta):
	set_StateMachinePlayer_parameters()


func emit_trigger(trigger_name: String):
	smp.set_trigger(trigger_name)





func _on_playerEnteredArea_body_entered(body: Node):
	if $kouboldMeetup / AnimationPlayer.assigned_animation == "kay_alert": return
	if body.get_name() == "playerChar":
		if Globals.get_player().current_health < 3:
			emit_trigger("player_entered_not_clothed")
		elif not is_already_waved:
			emit_trigger("player_entered_clothed")
			is_already_waved = true


func _wolf_walk_finished():
	emit_trigger("woof_walk_finished")


func _on_KouboldAnimationPlayer_animation_finished(anim_name: String):
	emit_trigger("anim_finished")


func _on_aimKoubsWoof_area_entered(area: Area2D):
	var player = Globals.get_player()
	if area.get_name() == "tempAimKoubsWoof":
		emit_trigger("player_aimed")


func _on_kayHugTimer_timeout():
	if is_hug:
		emit_trigger("kay_hug_timeout")



func _on_shiverTimer_timeout():
	if not Achievements.is_meetup_quest_complete:
		emit_trigger("shiver_timeout")


func _on_startScarfOfferTimer_timeout():
	emit_trigger("start_scarf_offer")


func _player_grappled():
	$CanvasLayer / AnimationPlayer.play("RESET")
	$aimKoubsWoof / CollisionShape2D.disabled = true
	is_player_grappled = true


func _player_grapple_freed():
	
	if $playerExitedArea.get_overlapping_bodies() != null:
		if Globals.get_player() in $playerExitedArea.get_overlapping_bodies():
			_wolf_walk_finished()
			is_player_grappled = true



func _on_teleportWoofToMox_timeout():
	wolf_inst.global_position = Globals.get_player().global_position


func _on_encounterArea_body_entered(body: Node):
	if Achievements.is_mox_meetup_ready():
		Achievements.is_woof_and_koubold_encountered = true




func _miniquest_hug():
	if not is_hug:
		ScreenManager.fade(0.08, 0.4)
	is_hug = true


func _stop_miniquest_hug():
	if not is_hug:
		return
	is_hug = false


func aggrevate_wolf():
	for i in range(5):
		wolf_inst.take_damage(1, Vector2(), 100, - 10)

	$teleportWoofToMox.start()
	wolf_inst.show()


func interacted():
	if Achievements.is_meetup_quest_complete:
		_miniquest_hug()
	elif Achievements.is_scarf_found:
		_show_tape()
		Achievements.snack_found()
		Achievements.complete_miniquest()
	else:
		$questionPopup.restart()
		$questionPopup.emitting = true
		$questionPopup2.restart()
		$questionPopup2.emitting = true


func _show_tape():
	$kouboldMeetup / AnimationPlayer.play("kay_eat")
	$scarf / AnimationPlayer.play("kay_eat")
	$scarf.show()
	$Broom.hide()
	for node in get_tree().get_nodes_in_group("Tape"):
		node.enable()


func spawn_clothes():
	var clothe = clothes.instance()
	add_child(clothe)
	clothe.global_position = $clothePosition.global_position
	clothe.scale = Vector2(0.5, 0.5)
	clothe.set_filename("res://Src/Interactables/clothes.tscn")
	clothe.set_owner(self)
		

