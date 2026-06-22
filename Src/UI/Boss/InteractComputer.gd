extends Interactable

export (bool) var can_be_active = true
var is_interacted: bool = false

func _input(event):
	if event.is_action_released("ui_down") and is_interacted and can_be_active:
		$InteractModules / ProgressBar.stop_progress()
		$AnimationPlayer.play_backwards("fade")



func _ready():
	add_to_group("Interactable")


func interacted():
	if not can_be_active:
		return

	if not is_interacted:
		$AnimationPlayerDisclaimer.play("fade")

	is_interacted = true
	for node in $InteractModules.get_children():
		node.interacted()
	$AnimationPlayer.play("fade")
	$TryBoss.visible = true



func change_scene_to_boss_area():
	PosManager.curr_start_pos = "computer"
	for node in $SecondaryInteractModules.get_children():
		node.interacted()



func _player_exited():
	if is_interacted:
		$AnimationPlayerDisclaimer.play_backwards("fade")
	player_entered = false
	is_interacted = false
	$TryBoss.visible = false
	$InteractModules / ProgressBar.stop_progress()
			
