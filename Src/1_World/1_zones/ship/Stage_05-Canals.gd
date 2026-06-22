extends Stage

export (bool) var debug_player_start_place = false

func _ready():
	_generic_ready()
	if debug_player_start_place:
		var p = Globals.get_player()
		p.global_position = $doors_transitions / playerPos.global_position
		
	
	$Control / CanvasLayer2 / diiibs.hide()
	if not SoundManager.is_music_playing("m_floating_cities"):
		SoundManager.play_music("m_floating_cities", 5.8)


var has_not_shown_title_yet: bool = true
func _on_showTitleScreen_body_entered(body):
	if has_not_shown_title_yet and body.get_name() == "playerChar":
		$Control / CanvasLayer2 / diiibs.show()
		$Triggers / showTitleScreen / Timer.start(2.5)
		$Control / CanvasLayer2 / diiibs / AnimationPlayer.play("fade_in_title")
		has_not_shown_title_yet = false


func _on_showTitleScreen_body_exited(body):
	if body.get_name() == "playerChar":
		if has_not_shown_title_yet == false and not $showTitleScreen / Timer.is_stopped():
			$Control / CanvasLayer2 / diiibs / AnimationPlayer.play("fade_out_title")
			has_not_shown_title_yet = false


func _on_Timer_timeout():
	$Control / CanvasLayer2 / diiibs / AnimationPlayer.play("fade_out_title")
	


func _on_changeToDark2_body_entered(body):
	if body.get_name() == "playerChar":
		emit_signal("new_time", "dark")
	pass