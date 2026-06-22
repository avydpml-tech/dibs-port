extends Interactable

export (String, "dark", "light", "bright") var lighting_state_1 = "dark"
export (String, "dark", "light", "bright") var lighting_state_2 = "bright"

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
	$"Enter 3/AnimationPlayer".play("clicked")
	
	var boolean = Globals.get_player().get_lighting_condition() == lighting_state_1

	if boolean:
		new_time(lighting_state_2)
		$lever_up.play()
		
	else:
		new_time(lighting_state_1)
		$lever_down.play()
	
	$"Enter 1".visible = not boolean
	
	
	
func new_time(day):
	for p in get_tree().get_nodes_in_group("Player"):
		p._on_Node2D_new_time(day)


func _show_silhouette(): $"Enter 3".show()
	
func _hide_silhouette(): $"Enter 3".hide()


func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed) and player_entered:
		interacted()


func _on_Area2D_mouse_entered():
	
	pass
