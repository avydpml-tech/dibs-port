extends KinematicBody2D




export (int) var SPEED = 80
export (int) var FASTER_SPEED = 250
export (bool) var disabled: bool = false setget _set_disabled
export (bool) var disable_movement: bool = false
export (bool) var insta_saucy: bool = false
export (bool) var point_to_player: bool = true
export (bool) var pull_player: bool = false
export (bool) var is_dash: bool = false
export (bool) var is_newspaper: bool = false
export (float, 0, 10) var dash_amount = 4.5
export (Texture) var five_frame_texture = null setget _set_texture

onready var sprite_anim = $Sprite / AnimationPlayer

var curr_speed = 0
var movedir = Vector2()
var player = null


func _ready():
	if not disabled:
		add_to_group("Tenticons")
	
	curr_speed = SPEED
	
	if is_dash:
		$dashTimer.start()


func _process(delta):
	sprite_anim.play("tentacle")

	if player == null: return

	change_speed()

	if point_to_player:
		look_at(player.global_position)

	if is_dash:
		check_if_stopped()


func _physics_process(delta):
	if player == null: return

	if not (disable_movement):
		move_to_player(delta)

	move_and_slide(velocity)

	
	if pull_player:
		pull_player()
		tentacle_leash_to_player()



func _draw():
	if is_newspaper:
		draw_line(Vector2.RIGHT * 50, Vector2.RIGHT * 200, Color(0.662745, 0.662745, 0.662745, 0.5), 1.5)






var velocity = Vector2()
var direction = Vector2()

var acceleration = 0.2
var friction = 0.05
var weight = 0

func move_to_player(delta):
	if not is_dash:
		direction = player.global_position - global_position
		weight = acceleration
	else:
		direction = Vector2.ZERO
		weight = friction

	velocity = lerp(velocity, direction.normalized() * (curr_speed * 2), weight)


func dash_to_player():
	direction = player.global_position - global_position
	velocity = direction * dash_amount
	
	


func _on_dashTimer_timeout():
	dash_to_player()
	if is_newspaper:
		$AnimationPlayer.play("newspaper_swat")
	$dashTimer.start()
	point_to_player = true








var should_speed: bool = false
func _input(event):
	if event.is_action_pressed("ui_right_mouse"):
		should_speed = true
	elif event.is_action_released("ui_right_mouse"):
		should_speed = false


func _set_disabled(is_disabled):
	disabled = is_disabled
	if is_in_group("Tenticons"):
		remove_from_group("Tenticons")


func _set_texture(new_texture):
	$Sprite.texture = new_texture


func set_player(p):
	player = p





func _handle_speed():
	pass

func check_if_stopped():
	point_to_player = (velocity <= Vector2(5, 5)) and is_dash

func change_speed():
	var player_naked = (Globals.get_player().current_health <= 0)
	curr_speed = FASTER_SPEED if player_naked or should_speed else SPEED


func pull_player():
	player.position.y += 1.5 if player.position.y < position.y else - 1.5
	if player.position.x != position.x:
		player.position.x += 1.5 if player.position.x < position.x else - 1.5
	else:
		player.position.x = 0


func knockback(player_pos, knockback_force):
		
		
		velocity.x = - knockback_force if global_position.x < player_pos.x else knockback_force
		
		velocity.y = - knockback_force if global_position.y < player_pos.y else knockback_force


func tentacle_leash_to_player():
	$leash.visible = true if pull_player else false
	var d = player.global_position.distance_to(self.global_position)
	$leash.scale.y = d / 110


func reduce_player_stamina(delta):
	Globals.get_player().decrease_stamina(delta * 10)
