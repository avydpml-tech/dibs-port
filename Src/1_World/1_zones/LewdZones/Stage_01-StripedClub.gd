extends Stage

var is_west_wing_fade_shown: bool = false
func _on_blackCoverEntered_body_entered(body: Node):
	if not is_west_wing_fade_shown:
		$ForeInteractacbles / Node2D / AnimationPlayer.play("fadeout")
	$Background / CanvasModulate.color = Color(0.270588, 0.388235, 0.4)
	is_west_wing_fade_shown = true

func _on_blackCoverExit_body_entered(body: Node):
	if is_west_wing_fade_shown:
		$ForeInteractacbles / Node2D / AnimationPlayer.play_backwards("fadeout")
	$Background / CanvasModulate.color = Color(0.466667, 0.396078, 0.501961)
	
	is_west_wing_fade_shown = false
