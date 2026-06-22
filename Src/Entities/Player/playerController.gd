extends Entity
const SLOPE_STOP = 64

var velocity = Vector2()
var move_speed = 5 * 96
var gravity = 1200
var jump_velocity = - 720

func physics_process(delta):
	_get_input()
	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, UP, SLOPE_STOP)


func _get_input():
	var move_direction = - int(Input.is_action_just_pressed("ui_left")) + int(Input.is_action_just_pressed("ui_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_velocity
		
	
	if move_direction != 0:
		
		
		$Body.scale.x = move_direction

func _get_h_weight():
	return 0.2 if is_on_floor() else 0.1
