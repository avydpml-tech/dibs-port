extends Node2D


export (String) var unique_id = ""
export (bool) var activated = false
var player_entered: bool = false

func _ready():
	add_to_group("Interactable")



func interacted():
	var something = get_node("AudioStreamPlayer2D")
	
	something.play()
	pass


func _player_entered():
	_show_silhouette()
	player_entered = true
	
func _player_exited():
	_hide_silhouette()
	player_entered = false
	
func _show_silhouette():
	pass
	
func _hide_silhouette():
	pass
