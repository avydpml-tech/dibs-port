extends Area2D

export (float) var SPEED = 1500
export (float) var DAMAGE = 3
export (float) var spread = 0
export (float) var time_duration = 0
export (float) var knock_back = 100

var velocity
var direction = ""
onready var sprite = $visualFluff / projectileSprite

func _ready():
	add_to_group("Bullet")
	$Timer.start(time_duration)
	set_as_toplevel(true)


func _enter_tree():
	pass


func get_name():
	return "Bullet"






func _start(_position: Vector2, _parent_rotation):
	
	
	var spread_in_deg = spread if randf() > 0.5 else - spread
	var spread_in_rad = deg2rad(spread_in_deg)
	var dir = Vector2.RIGHT.rotated(_parent_rotation + spread_in_rad)
	
	_assign_input(_position, dir)


func _assign_input(_position, _direction: Vector2):
	position = _position
	rotation = _direction.angle()
	velocity = _direction * SPEED


func _physics_process(delta):
	bullet_movement(delta)
	face_direction()
	
	
	


func face_direction():
	direction = "right" if velocity.x > 0 else "left"
	


func bullet_movement(delta):
	
	
	
	
	
	position += velocity * delta
	


func is_enemy( var body):
	return true if body.is_in_group("Nonplayer") else false


func _on_VisibilityNotifier2D_screen_exited():
	hide()


func _on_Timer_timeout():
	call_deferred("free")


func emit_hit():
	var inst = $visualFluff / CPUParticles2D2.instance
	inst.emitting = true
	get_parent().add_child(inst)
	

func _on_selfArea_body_entered(body):
	
	if is_enemy(body):
		var Nonplayer = body
		Nonplayer.take_damage(DAMAGE, direction, knock_back)
		call_deferred("free")
	
	
	elif body.get_name() in ["shieldmonShield", "shieldmonShield2"]:
		body.get_owner().plink()
		call_deferred("free")

	elif body.is_in_group("CanBeShot"):
		body.shot(DAMAGE)
		SoundManager.play_smart_audio("enemy_hit")
		call_deferred("free")
		
	else:
		call_deferred("free")
