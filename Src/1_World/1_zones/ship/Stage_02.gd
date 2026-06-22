extends Stage


func player_stood_up():
	$background / ShipControls / AnimationPlayer.play("window_down")
	Globals.get_player().get_node("playerSprite").global_position.x = $Foreground / seat.global_position.x


func player_seated():
	$background / ShipControls / AnimationPlayer.play_backwards("window_down")

func start_end_credits():
	SoundManager.play_music("m_space_jazz")
	Globals.get_player().disable_input()
	$background / ShipControls / AnimationPlayer.play("ending_start")


func _on_OptionsButton2_pressed():
	start_end_credits()

func start_ending():
	EndingsManager.start_ending("ship")
