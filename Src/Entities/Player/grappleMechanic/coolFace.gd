extends KinematicBody2D

export (NodePath) var follow_body_path = null

var target_pos = Vector2()
var velocity = Vector2()
var speed: int = 10
var is_near_corner: bool = false


func _ready():
	$coolFace / AnimationPlayer.play("cheeky_face_pop_up")
	self.global_position = get_node(follow_body_path).global_position


func _physics_process(delta):
	target_pos = get_node(follow_body_path).global_position
	self.global_position = self.global_position.linear_interpolate(target_pos, delta * speed)


func _input(event):
	if event.is_action_pressed("ui_right_mouse") and not is_near_corner:
		show_popup()
	elif event.is_action_released("ui_right_mouse") and not is_near_corner:
		hide_popup()


func show_popup():
	$coolFace / AnimationPlayer.play("pop_up")

func hide_popup():
	$coolFace / AnimationPlayer.play_backwards("pop_up")


func _on_detectCornerTenta_body_entered(body):
	if body.is_in_group("TentacleArm"):
		show_popup()

func _on_detectCornerTenta_body_exited(body: Node):
	if body.is_in_group("TentacleArm"):
		hide_popup()