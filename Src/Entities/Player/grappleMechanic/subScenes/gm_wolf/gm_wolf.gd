extends Node2D


func _ready():
	if Achievements.is_woof_and_koubold_encountered:
		$"wolfEyes3/AnimationPlayer".play("angry_to_soft")
		$wolfEyes.hide()
		$wolfEyes3.show()
		$heartToDisappointed.show()
		$tentacle.hide()
		$tentacle.disabled = true
	else:
		$wolfEyes3.hide()
		$wolfEyes.show()
		$"wolfEyes/AnimationPlayer".play("angry_to_soft")
		$heartToDisappointed.hide()
		$tentacle.show()


func calmed_down():
	$tentacle / heartAnimations.play("fade_in")
	

func drop_mox():
	
	get_parent().get_parent().grapple_finished("player_won")


func _on_heartToDisappointed_body_entered(body: Node):
	if body.get_name() == "player":
		
		$"wolfEyes3/AnimationPlayer".stop(true)
		$"wolfEyes3/AnimationPlayer".play("seriously")
		$heartToDisappointed.call_deferred("set_monitoring", false)
		$heartToDisappointed.call_deferred("hide")
