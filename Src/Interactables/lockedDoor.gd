extends StaticBody2D


export (String) var unique_id = ""
export (String, "up", "slow_up", "very_slow_up", "hide") var interact_anim = ""
export (int) var volume_distance = 10000
export (bool) var activated = false

onready var anim = $AnimationPlayer


func _ready():
	$clang.set_max_distance(volume_distance)
	$ambient.set_max_distance(volume_distance)
	
	if activated:
		item_activated()
	
	
func _enter_tree():
	add_to_group(unique_id)
	add_to_group(get_name())

func item_activated():
	anim.set_current_animation(interact_anim)
	anim.seek(4.5, true)
	anim.stop(false)

func _interacted_by_obj():
	activated = true
	$AnimationPlayer.play(interact_anim)
	ItemManager.save_item(self.save())

func _interacted_by_EventManager(variant):
	_interacted_by_obj()




	
func save():
	var save_dict = {
		"unique_id": unique_id, 
		"parent_path": get_parent().get_path(), 
		"owner_path": get_owner().get_filename(), 
		"activated": activated, 
		
		
	}
	return save_dict

func _on_Area2D_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
