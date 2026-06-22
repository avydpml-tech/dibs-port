extends Nonplayer











export (float) var sprint_speed = 300

onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite
onready var shield_head = $shieldmonHead
var is_shielded: bool = true setget is_shielded_changed
var enemy_state = "idle"


func _ready():
	_generic_ready()
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()
	should_show_shieldhead()

func _process(_delta):
	animate_sprite()


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()




func _on_attackRange_body_entered(body):
	check_for_player_in_attack_range(body)

	if not is_shielded:
		check_if_player_in_attack_body(body)

func _on_attackRange_body_exited(body):
	attack_body = null
	_is_player_in_attack_range = false


var _is_player_in_attack_range: bool = false
func check_for_player_in_attack_range(body):
	_is_player_in_attack_range = true if Globals._is_player(body) else false
		
func _check_attackRange_when_creature_turn():
	if dir != new_dir and not is_shielded:
		check_if_player_in_attack_body()
		new_dir = dir

func alerted():
	if is_shielded and not SettingsManager.is_exploration_mode:
		self.is_shielded = false





func is_shielded_changed(boolean = true):
	
	if is_shielded and not SettingsManager.is_exploration_mode:
		_creature_sounds("skitter")
		_creature_sounds("screech")
	
	is_shielded = boolean
	
	$shieldmonShield / CollisionShape2D.disabled = true
	$shieldmonShield2 / CollisionShape2D.disabled = true
	
	if not is_shielded:
		call_deferred("change_move_speed", sprint_speed)
		
	shield_head.call_deferred("hide")
	call_deferred("instance_shields")

func should_show_shieldhead():
	if is_shielded:
		shield_head.call_deferred("show")

	

func instance_shields():
	var right_shield = load("res://Src/Entities/Nonplayer/f_subtypes/f_shieldmon/rightShield.tscn").instance()
	var left_shield = load("res://Src/Entities/Nonplayer/f_subtypes/f_shieldmon/leftShield.tscn").instance()

	left_shield.global_position = $shieldPositions / left.global_position
	right_shield.global_position = $shieldPositions / right.global_position

	get_parent().call_deferred("add_child", right_shield)
	get_parent().call_deferred("add_child", left_shield)




func monitor_shield_health():
	if current_health != max_health:
		
		if is_shielded != false:
			self.is_shielded = false


func change_move_speed(new_speed):
	move_speed = new_speed







func animate_sprite():
	if is_on_floor():
		
		if enemy_state in ["stunned", "afterglow", "sleep"]:
			change_anim_state("idle")
		elif enemy_state in ["chase"]:
			change_anim_state("run")
		else:
			change_anim_state(enemy_state)

		if player == null:
			if velocity.x > 0:
				norm_sprite.flip_h = true
				shield_head.flip_h = true

			elif velocity.x < 0:
				norm_sprite.flip_h = false
				shield_head.flip_h = false
		else:
			if dir == "right":
				norm_sprite.flip_h = true
				shield_head.flip_h = true
			else:
				norm_sprite.flip_h = false
				shield_head.flip_h = false


func change_anim_state(new_state):
	if norm_sprite_anim.assigned_animation != new_state:
		if is_shielded:
			new_state = "shield_" + new_state
		
		norm_sprite_anim.play(new_state)


func plink():
	if is_shielded:
		$Audio / unsatisfyingHit.play()
		$normSprite / shieldHit.play("shield_hit")


func _on_hit_animation_finished(_anim_name):
	modulate = "ffffff"

func _on_shieldHit_animation_finished(_anim_name):
	norm_sprite.modulate = "ffffff"
	
func _creature_sounds( var state):
	match state:
		"screech": $Audio / skitter.play()
		"skitter": $Audio / screech.play()
		"fire": $Audio / fire.play()
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()

