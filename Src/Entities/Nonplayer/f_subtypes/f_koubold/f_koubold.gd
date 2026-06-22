extends Nonplayer











onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite
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
	






func take_damage( var dmg: int, var posi = Vector2(), var knock_back_force = 100):
	hpStat(dmg, "dmg")
	if allow_knock_back:
		knock_back(knock_back_force, posi)
	$hit.play("hit_indication")
	just_shot_at = true











	














	


	













	












































				



















	









