extends Interactable

signal new_time
var day
var play_sound: bool = false

func _ready():
	$"Enter 3".hide()
	$Area2D.show_on_top = true

	call_deferred("scene_just_started")

	
func scene_just_started():
	if activated:
		call_deferred("interacted")
		set_deferred("play_sound", true)

func interacted():
	if not $interactTimer.is_stopped(): return
	
	for light in get_tree().get_nodes_in_group("Lights"):
		activated = light.visible
		light.visible = not light.visible
		$"Enter 1".visible = light.visible
		day = "dark" if light.visible else "bright"
		if play_sound:
			$lever_up.play()
		
	$"Enter 3/AnimationPlayer".play("clicked")
	new_time()

	$interactTimer.start()

	
	
	
	
	
	
	
	
	
	
	ItemManager.save_item(self.save())
	
	
func new_time():
	for p in get_tree().get_nodes_in_group("Player"):
		p._on_Node2D_new_time(day)


func _show_silhouette(): $"Enter 3".show()
	
func _hide_silhouette(): $"Enter 3".hide()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) and player_entered:
		interacted()


func _on_Area2D_mouse_entered():
	pass
