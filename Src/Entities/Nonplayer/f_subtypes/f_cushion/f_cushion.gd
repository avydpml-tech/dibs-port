extends Node2D

var player
func _ready():
	add_to_group("Interactable")
	player = Globals.get_player()

func _input(event):
	if (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or player.one_handed_movement) and Globals.get_player().is_disabled():
		player.enable_mox()
		$Sprite / AnimationPlayer.play("hello")

	if (event.is_action_pressed("ui_down") or event.is_action_released("ui_scroll_down"))\
	and player.player_state == "idle":
		if player in $clothesRange.get_overlapping_bodies():
			player._add_health(3)
			$Sprite / AnimationPlayer.play("hello")


func _on_seePlayerRange_body_entered(body: Node):
	if player.current_health == 3:
		$Sprite / AnimationPlayer.play("hello")
	else:
		if not $Sprite / AnimationPlayer.assigned_animation == "clothe":
			$Sprite / AnimationPlayer.play("clothe")



func interacted():
	player._clear_coom_count()

	if player.player_state == "idle" and player.current_health < 3:
		Globals.get_player().disable_mox()
		$Sprite / AnimationPlayer.play("sauce")
	elif player.player_state == "idle" and player.current_health == 3:
		Globals.get_player().disable_mox()
		$Sprite / AnimationPlayer.play("massage")

	if player.player_state == "run":
		$Sprite / AnimationPlayer.play("highfive")


func _on_detectPlayerNear_body_exited(body: Node):
	pass

func _on_detectPlayerNear_body_entered(body: Node):
	pass

func _player_entered():
	$ArrowUp.show()

func _player_exited():
	$ArrowUp.hide()

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name in ["hello", "slap_other_plants_left", "slap_other_plants_right"]:
		$Sprite / AnimationPlayer.play("rest")


func _on_clothesRange_body_entered(body: Node):
	if $Sprite / AnimationPlayer.assigned_animation == "clothe":
		$ArrowUpClothes.show()


func _on_clothesRange_body_exited(body: Node):
	$ArrowUpClothes.hide()
	pass


func _on_detectNonplayerLeft_body_entered(body: Node):
	if body.get_class() == "Nonplayer":
		player.enable_mox()
		$Sprite / AnimationPlayer.play("slap_other_plants_left")
	

func punk_all_plants():
	for p in $seePlayerRange.get_overlapping_bodies():
		if p.get_class() == "Nonplayer":
			p.take_damage(100)


func _on_detectNonplayerRight_body_entered(body: Node):
	if body.get_class() == "Nonplayer":
		player.enable_mox()
		$Sprite / AnimationPlayer.play("slap_other_plants_right")


func add_player_stamina():
	player.add_stamina(3)
