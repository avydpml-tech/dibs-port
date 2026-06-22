extends KinematicBody2D

export (int) var SPEED = 100
export (int) var knockback_force = 500
export (int) var damage = 5
export (float, 0, 3) var iframe_sec = 1.2
export (NodePath)onready var minigame_manager = get_node(minigame_manager)

onready var iframe_timer = $iFrameTimer


var movedir = Vector2()
var target


signal body_entered_player

func _ready():
	
	
	
	yield(get_tree(), "idle_frame")
	set_deferred("target", get_global_mouse_position())
	get_tree().call_group("Tenticons", "set_player", self)



	iframe_timer.start(iframe_sec)
	_player_detect_area(false)


func _physics_process(_delta):
	controls_loop()
	movement_loop()


func controls_loop():
	var LEFT = Input.is_action_pressed("ui_left")
	var RIGHT = Input.is_action_pressed("ui_right")
	var UP = Input.is_action_pressed("ui_up")
	var DOWN = Input.is_action_pressed("ui_down")
	
	if LEFT or RIGHT or UP or DOWN:
		movedir.x = - int(LEFT) + int(RIGHT)
		movedir.y = - int(UP) + int(DOWN)
	elif SettingsManager.is_one_handed_mode and not Globals.is_using_controller:
		target = get_global_mouse_position()
		if position.distance_to(target) < 30:
			movedir = Vector2(0, 0)
			return

		movedir = (target - position)
	else:
			movedir = Vector2(0, 0)


func movement_loop():
	
		
		
		
	
	
	

	var motion = movedir.normalized() * SPEED
	move_and_slide(motion, Vector2(0, 0))
		
func _on_iFrameTimer_timeout():
	_player_detect_area(true)

func _player_detect_area(boolean):
	$playerDetect.monitorable = boolean
	$playerDetect.monitoring = boolean



func _on_playerDetect_body_entered(body):
	var is_in_tenticon = body in get_tree().get_nodes_in_group("Tenticons")
	var is_in_arm = body in get_tree().get_nodes_in_group("TentacleArm")

	if not (is_in_tenticon or is_in_arm): return

	if is_in_tenticon:
		if body.is_newspaper:
			get_owner().grapple_finished("break_free_no_decrease_stamina")
			return
		else:
			get_owner().rip_or_saucy(body.insta_saucy)
			return

	if is_in_arm:
		get_owner().rip_or_saucy(true)
		return
	else:
		get_owner().rip_or_saucy(body.insta_saucy)
