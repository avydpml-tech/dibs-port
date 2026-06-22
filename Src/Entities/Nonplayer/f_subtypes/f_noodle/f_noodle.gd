extends Nonplayer











export (bool) var can_plop_to_ground = true
export (float, 0, 4) var plop_to_ground_sec = 1.5
export (String, "chase_when_flashed", "plop_when_flashed") var noodle_behavior = "chase_when_flashed"


onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite

var enemy_state = "idle"
var should_plop_to_ground: bool = false

func _ready():
	_generic_ready()
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()

	get_node("lightVignette").show()
	if noodle_behavior == "chase_when_flashed":
		should_plop_to_ground = true


func _process(_delta):
	animate_sprite()


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()
	





func flashed_by_flashlight():
	if flashed: return
		
	player = Globals.get_player()
	flashed = true

	if noodle_behavior == "chase_when_flashed":
		should_plop_to_ground = false
		$flashedTimer.start(plop_to_ground_sec * 2)
	if noodle_behavior == "plop_when_flashed":
		should_plop_to_ground = can_plop_to_ground

	

func not_flashed_anymore():
	if not flashed: return

	
	flashed = false
	
	if noodle_behavior == "plop_when_flashed":
		$flashedTimer.start(plop_to_ground_sec)

func flashed(boolean):
	flashed = boolean
		
func _on_flashedTimer_timeout():
	if not flashed:
		if noodle_behavior == "chase_when_flashed":
			should_plop_to_ground = true
		
		if noodle_behavior == "plop_when_flashed":
			should_plop_to_ground = false
			call_deferred("check_if_player_in_attack_body")

func plop_to_ground(should_plop: bool):
	gravity_enabled = should_plop
	float_to_player = not should_plop

	
	
	var should_monitor = not should_plop if noodle_behavior == "plop_when_flashed" else true
	$detectBodies / attackRange.monitorable = should_monitor
	$detectBodies / attackRange.monitoring = should_monitor




func animate_sprite():
	pass


func _on_hit_animation_finished(_anim_name):
	modulate = "ffffff"

	
func _creature_sounds( var state):
	match state:
		
		
		
		"screech": pass
		"skitter": pass
		"fire": pass
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()