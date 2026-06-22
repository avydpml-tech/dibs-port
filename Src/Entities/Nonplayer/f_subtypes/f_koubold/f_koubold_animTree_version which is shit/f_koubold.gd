extends Nonplayer










onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite
onready var anim_state_machine = $normSprite / AnimationTree.get("parameters/playback")
onready var climb_timer = $Timers / climbTimer
onready var idle_chase_timer = $Timers / idleBeforeChaseTimer
onready var ceiling_raycast = $ceilingRayCast

export (float) var climb_cooldown = 0.1
export (float) var chase_cooldown = 0.1

var enemy_state = "idle"


func _ready():
	_generic_ready()
	
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()

func _process(_delta):
	animate_sprite()


func take_damage( var dmg: int, var posi = Vector2(), var knock_back_force = 100):
	hpStat(dmg, "dmg")
	if allow_knock_back:
		knock_back(knock_back_force, posi)
	$hit.play("hit_indication")
	just_shot_at = true



func _teleport_behind_player():
	

	
	

	var temp_player = Globals.get_player()
	var temp_posi = Vector2(0, 0)
	var spawn_dist = 550
	
	temp_posi = temp_player.global_position

	temp_posi.x += spawn_dist if temp_player.dir == "left" else - spawn_dist
	temp_posi.y -= 80

	global_position = temp_posi


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()
	






var looked_down: bool
var should_climb: bool
var just_shot_at: bool
var norm_sprite_anim_finished: bool = false

























func set_norm_sprite_anim_finished():
	norm_sprite_anim_finished = true

	
	
	








func _run_away():
	if Globals.get_player().global_position.x > global_position.x: dir = "left"
	elif Globals.get_player().global_position.x < global_position.x: dir = "right"







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
		
		
		
		
		
		
		


func _on_deathAnimationPlayer_animation_finished(_anim_name):
	is_alive = false
	EntityManager.call_deferred("save_entity", save())
	call_deferred("free")
	

func _on_hit_animation_finished(_anim_name):
	modulate = "ffffff"

	
func _creature_sounds( var state):
	match state:
		"screech": pass
		"skitter": pass
		"fire": $Audio / fire.play()
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()

