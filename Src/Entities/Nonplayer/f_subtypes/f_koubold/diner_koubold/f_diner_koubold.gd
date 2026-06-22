extends KinematicBody2D
var is_given_food: bool = false

func _enter_tree():
	add_to_group("CanBeFlashed")
	add_to_group("Interactable")



onready var koubold_anim_state_machine = $kouboldAnimationTree.get("parameters/playback")

func _ready():
	if not Achievements.is_club_door_unlocked or Achievements.is_mox_meetup_ready():
		call_deferred("queue_free")

	if not Globals.get_player().is_connected("player_coomed", self, "_spawn_tape"):
		if Globals.get_player().connect("player_coomed", self, "_spawn_tape") != OK:
			print(self, ": player_coomed signal not connecting to _spawn_tape()")

	for tape in get_tree().get_nodes_in_group("Tape"):
		tape.hide()
		tape.disabled = true
	
	$saucyButton.hide()


func _process(delta):
	if Globals.get_player().player_state == "saucied":
		hide()
		Achievements.is_saucied_koubold = true

	else:
		show()


func interacted():
	if Achievements.is_snack_empty() and Achievements.koubold_snack_given_arr == []:
		$questionPopup.restart()
		$questionPopup.emitting = true
		_on_detectHeadturn_body_entered(Globals.get_player())
		return
	
	if not Achievements.is_snack_empty() and not is_given_food:
		
		given_food("snack")


func given_food(food: String):
	print("Koubold given snacks. Happy.")
	$Food / AnimationPlayer.play("given_food")
	koubold_anim_state_machine.travel("given_food")
	Achievements.koubold_snack_given_arr.append(food)
	$Arrow.hide()
	is_given_food = true


func flashed_by_flashlight():
	koubold_anim_state_machine.travel("koubold_hide")
	$hideTimer.start()

	$exclaimPopup.emitting = true

func not_flashed_anymore():
	pass


func _spawn_tape():
	for tape in get_tree().get_nodes_in_group("Tape"):
		tape.show()
		tape.disabled = false





func _on_seePlayerRange_body_entered(body: Node):
	if Globals._is_player(body) and $hideTimer.is_stopped():

		
		
		
		if not koubold_anim_state_machine.get_current_node() == "koubold_head_turn":
			koubold_anim_state_machine.travel("koubold_look_up")


func _on_seePlayerExit_body_exited(body: Node):
	if Globals._is_player(body) and $hideTimer.is_stopped():
		koubold_anim_state_machine.travel("koubold_idle")
		$saucyButton.hide()


func _on_detectPlayerNear_body_entered(body: Node):
	if Globals._is_player(body) and not Achievements.koubold_snack_given_arr.empty():
		$saucyButton.show()
		$saucyButton.is_saucied = true
	elif Globals._is_player(body):
		$Arrow.show()


func _on_detectPlayerNear_body_exited(body: Node):
	if Globals._is_player(body):
		$saucyButton.hide()
		$Arrow.hide()
		$saucyButton.is_saucied = false


func _on_detectHeadturn_body_entered(body):
	if not Globals._is_player(body):
		return
	if not $hideTimer.is_stopped():
		return

	if Globals.get_player().global_position < global_position:
		koubold_anim_state_machine.travel("koubold_head_turn")
	elif (Globals.get_player().global_position > global_position):
		koubold_anim_state_machine.travel("koubold_head_turn_back")


func _on_detectHeadturn_body_exited(body):
	if not Globals._is_player(body):
		return
	if not $hideTimer.is_stopped():
		return

	if Globals.get_player().global_position > global_position:
		koubold_anim_state_machine.travel("koubold_head_turn_back")
	if Globals.get_player().global_position < global_position:
		koubold_anim_state_machine.travel("koubold_head_turn")


func _on_Timer_timeout():
	if koubold_anim_state_machine.get_current_node() == "koubold_hide":
		koubold_anim_state_machine.travel("koubold_show_up")
	

func _player_entered():
	pass

func _player_exited():
	pass


signal koubold_found
func _on_kouboldFound_body_entered(body: Node):
	if body.get_name() != "playerChar": return
		
	if not self.is_connected("koubold_found", Achievements, "koubold_found"):
		self.connect("koubold_found", Achievements, "koubold_found")
	emit_signal("koubold_found")
