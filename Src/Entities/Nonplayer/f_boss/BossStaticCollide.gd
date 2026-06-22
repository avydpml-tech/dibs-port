extends StaticBody2D

export (Array) var player_states_can_collide = ["idle", "run", "jump", "fall"]

var tween = Tween.new()


func _ready():
	add_child(tween)


func _on_detectArea_body_entered(body: Node):
	if body.get_name() == "playerChar":
		$CollisionShape2D.set_deferred("disabled", true)
		knockback(body)
		$ResetTimer.start()
		grapple_player(body)


func knockback(body):
	return
	body.velocity.x += 1500
	

func _on_ResetTimer_timeout():
	$CollisionShape2D.disabled = false


func grapple_player(player):
	if player.can_be_saucied(player_states_can_collide) and not player.is_grappled:
		player.boss_grapple(self)
