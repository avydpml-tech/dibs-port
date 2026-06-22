extends Nonplayer










export (int) var pouncing_distance = 500
export (int) var pouncing_height = 700

onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite
onready var jump_timer = $jumpTimer


var enemy_state = "idle"
var temp_health = 0

func _ready():
	_generic_ready()
	
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()

func _process(_delta):
	animate_sprite()
	set_death_sprite()


func _should_jump():
	return

	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()

func jump_to_player():
	if player == null: return
	velocity.x = - pouncing_distance if player.global_position.x < global_position.x else pouncing_distance
	velocity.y = - pouncing_height

func on_floor():
	velocity.x = 0
	velocity.y = 0



func set_death_sprite():
	$deathSprite.frame = 2 if enemy_state == "jump" else 0



func take_damage( var dmg: int, var posi = Vector2(), var knock_back_force = 100):
	if enemy_state == "jump":
		dmg = dmg * 2
	hpStat(dmg, "dmg")
	if allow_knock_back:
		knock_back(knock_back_force, posi)
	is_asleep = false
	$hit.play("hit_indication")
	if allow_hit_sound:
		SoundManager.play_smart_audio("enemy_hit", 0)






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
		"skitter": $Audio / skitter.stop()
		"fire": $Audio / fire.play()
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()

