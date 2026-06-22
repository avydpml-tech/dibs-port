extends Nonplayer






onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite

var enemy_state = "idle"

func _ready():
	_generic_ready()
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()
	pass

func disable_creature():
	$lightVignette2.visible = false
	$normSprite / Anim.stop()
	$normSprite / lightVignette.hide()

func _process(_delta):
	animate_sprite(_delta)





func flashed(boolean):
	
		
	flashed = boolean

func flashed_by_flashlight():
	if flashed: return

	player = Globals.get_player()
	flashed = true
	alert_other_creatures()

func not_flashed_anymore():
	if not flashed: return

	
	flashed = false
	player = null
	_can_chase()



func alert_other_creatures():
	for Nonplayer in $alertRange.get_overlapping_bodies():
		if Nonplayer.is_in_group("Nonplayer") and Nonplayer != self:
			
			
			
			Nonplayer.force_chase(true, "alerted by " + self.get_name())
			Nonplayer.alerted()


func _on_sightLine_body_exited(body):
	if body.get_name() == "playerChar":
		player = null
		flashed = false


func _can_chase() -> bool:
	if SettingsManager.is_exploration_mode: return false
	if flashed: return true
	return false


func _should_stop_chase() -> bool:
	return true if (target_destination == null and not force_chase and not flashed) else false




func knock_back( var _force: int, var _dir):
	pass



func show_Nonplayer():
	self.show()
	

func take_damage( var dmg: int, var posi = Vector2(), var knock_back_force = 100):
	alert_other_creatures()
	hpStat(dmg, "dmg")
	if allow_knock_back:
		knock_back(knock_back_force, posi)
	$hit.play("hit_indication")
	SoundManager.play_bsfx("enemy_hit")

func _on_attackRange_body_entered(body):
	if enemy_state == "chase":
		check_if_player_in_attack_body(body)


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()
	





func animate_sprite(delta):
	\
\
\
\
	" \r\n\tidle_threshold is used for the character's stopping animation\r\n\tif we wait for the character's speed to reach 0, it would look weird.\r\n\tIt already stopped, yet it is still has 'run' animation\r\n\t"
	
	if is_on_floor():
		if enemy_state != "chase":
			if velocity.x > 0:
				norm_sprite.flip_h = true
				
			elif velocity.x < 0:
				norm_sprite.flip_h = false
			
		else:
			norm_sprite.flip_h = true if dir == "right" else false
			

			if Globals.get_player().global_position.y < global_position.y:
				var player_dir = Globals.get_player().global_position - norm_sprite.global_position
				var lerped_angle = lerp(norm_sprite.global_rotation, player_dir.angle(), delta * 20)
	
				norm_sprite.global_rotation = clamp(lerped_angle, deg2rad( - 125), deg2rad( - 45))
			else:
				var position = Globals.get_player().global_position.x < global_position.x
				norm_sprite.global_rotation = deg2rad( - 125) if position else deg2rad( - 45)
			
			

		
		
		
		
		
		
		


func _on_hit_animation_finished(_anim_name):
	modulate = "ffffff"

	
func _creature_sounds( var state):
	match state:
		"screech": $Audio / screech.play()
		"skitter": $Audio / skitter.play()
		"fire": $Audio / fire.play()
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()

