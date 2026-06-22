extends StaticBody2D




export (Array) var player_states_can_collide = ["idle", "run", "jump", "fall"]

var is_allow: bool = true
var tween = Tween.new()
var tween_duration: float = 0.02
var start_sweep_point: Vector2
var end_sweep_point: Vector2

func _ready():
	add_child(tween)
	add_to_group("floor_sweep")


func start_sweep(start_point, end_point):
	
	start_sweep_point = start_point
	end_sweep_point = end_point
	global_position = start_sweep_point
	is_allow = true

	set_deferred("modulate", Color("ffffff"))
	$CollisionShape2D.set_deferred("disabled", false)
	$detectArea / CollisionShape2D.set_deferred("disabled", false)

	
	var new_pos = Vector2(100, 0) if start_sweep_point.x > end_sweep_point.x else - Vector2(100, 0)
	rotation_degrees = 180 if start_sweep_point.x > end_sweep_point.x else 0


	tween.interpolate_property(self, "global_position", self.global_position, end_sweep_point + new_pos, tween_duration, Tween.TRANS_LINEAR)
	tween.interpolate_callback(self, tween_duration, "sweep_tail_end")
	tween.start()



func sweep_tail_end():
	tween.interpolate_property(self, "global_position", self.global_position, end_sweep_point, tween_duration / 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_callback(self, 0.5, "hide_sweep")
	tween.start()


func hide_sweep():
	var new_modulate = Color("00ffffff")
	tween.interpolate_property(self, "modulate", self.modulate, new_modulate, 0.05, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	$detectArea / CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	global_position = $HideSweepPoint.global_position


func _on_ResetTimer_timeout():
	$CollisionShape2D.disabled = false


func grapple_player(player):
	if player.can_be_saucied(player_states_can_collide) and not player.is_grappled:
		player.boss_grapple(self)


func knockback(body):
	return
	body.velocity.x += 1500


func _on_detectArea_body_entered(body: Node):
	if body.get_name() == "playerChar" and is_allow:
		is_allow = false
		$CollisionShape2D.set_deferred("disabled", true)
		knockback(body)
		$ResetTimer.start()
		grapple_player(body)
		tween.stop_all()
		global_position = $HideSweepPoint.global_position
