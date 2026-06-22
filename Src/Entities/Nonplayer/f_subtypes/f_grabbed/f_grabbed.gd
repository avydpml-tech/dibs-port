extends Nonplayer











func get_entity_name():
	return "grabbed"


func _ready():
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()

func _process(_delta):
	canDie()


func _on_sightLine_body_exited(body):
	if body.get_name() == "playerChar":
		player = null


func _on_deathAnimationPlayer_animation_finished(_anim_name):
	is_alive = false
	call_deferred("free")


func _on_attackRange_body_entered(body):
	check_if_player_in_attack_body(body)
