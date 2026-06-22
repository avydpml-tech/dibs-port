extends Nonplayer












onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite
onready var norm_sprite_2_anim = $normSprite2 / Anim

var enemy_state = "idle"


func _ready():
	_generic_ready()
	if enemy_state == "disabled":
		$normSprite / creatureLight.visible = false
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()
	pass

func _process(_delta):
	animate_sprite(_delta)







func flashed(boolean):
	
		
	flashed = boolean

func flashed_by_flashlight():
	if flashed: return
		
	player = Globals.get_player()
	flashed = true

func not_flashed_anymore():
	if not flashed: return

	
	flashed = false
	player = null
	_can_chase()


func _on_sightLine_body_exited(body):
	if body.get_name() == "playerChar":
		player = null
		flashed = false
		
func _can_chase() -> bool:
	
	if SettingsManager.is_exploration_mode: return false
	if player == null or is_player_near_chasing_range == false: return false
	return true




func knock_back( var _force: int, var _dir):
	pass



func show_Nonplayer():
	self.show()
	

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
	
	pass
	
	
	
	
				
	
	
			
	
	
	

	
	
	
	
	
	
	
	
			
	

		
		
		
		
		
		
		


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

