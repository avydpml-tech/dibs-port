extends Nonplayer











export (int, 0, 700) var increase_fall_range_x_axis = 338 setget set_fall_range

onready var norm_sprite_anim = $normSprite / Anim
onready var norm_sprite = $normSprite

var enemy_state = "hang"
	

func _ready():
	_generic_ready()
	
	$deathSprite / AnimationPlayer.stop()
	$deathSprite.hide()
	norm_sprite_anim.play("hang")


func _process(_delta):
	canDie()
	
	
	animate_sprite()
	


func set_fall_range(new_range):
	var collision_shape = $fallSightLine / CollisionShape2D.get_shape()
	collision_shape.set_extents(Vector2(new_range, 145.3))


func _should_jump():
	var left_raycast = $leftJumpRayCast
	var right_raycast = $rightJumpRayCast
	
	if left_raycast.is_colliding() or right_raycast.is_colliding():
		jump()
		

func _should_fall() -> bool:
	if current_health != max_health or should_fall:
		$fallSightLine.monitorable = false
		$fallSightLine.monitoring = false
		$fallSightLine / CollisionShape2D.disabled = true
		return true
	return false
	

var should_fall: bool = false
func _on_fallSightLine_body_entered(body):
	if body.get_name() == "playerChar":
		should_fall = true








func animate_sprite():
	
	var self_state = enemy_state
	if is_on_floor():
		
		
		

		
		
		
		if self_state in ["idle", "self_saucy", "stunned", "sleep"]:
			norm_sprite_anim.play("idle")
		else:
			norm_sprite.flip_h = true if velocity.x > 0 else false
			norm_sprite_anim.play("run")
		
		var is_climbing = $checkClimbSpriteLeft.is_colliding() or $checkClimbSpriteRight.is_colliding()
		
		norm_sprite.rotation_degrees = 90 if is_climbing else 0
		
		
	else:
		if self_state in ["hang", "fall"]:
			match self_state:
				"hang": norm_sprite_anim.play("hang")
				"fall": norm_sprite_anim.play("fall")


func _on_hit_animation_finished(anim_name):
	modulate = "ffffff"
	pass


func _creature_sounds( var state):
	match state:
		"screech": $Audio / skitter.play()
		"skitter": $Audio / screech.play()
		"fire": $Audio / fire.play()
		"stop_all":
			for audio in $Audio.get_children():
				audio.stop()


