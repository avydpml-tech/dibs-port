extends Nonplayer












onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite

var enemy_state = "idle"


func _ready():
	_generic_ready()
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()


func _process(_delta):
	animate_sprite()



func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()
	



func animate_sprite():
	
	
	\
\
\
\
	" \r\n\tidle_threshold is used for the character's stopping animation\r\n\tif we wait for the character's speed to reach 0, it would look weird.\r\n\tIt already stopped, yet it is still has 'run' animation\r\n\t"
	
	if is_on_floor():
		if player == null:
			if velocity.x > 0:
				norm_sprite.flip_h = true
				
			elif velocity.x < 0:
				norm_sprite.flip_h = false
		else:
			if dir == "right":
				norm_sprite.flip_h = true
			else:
				norm_sprite.flip_h = false
		
		
		
		
		
		
		


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

