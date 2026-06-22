extends Interactable

export (bool) var is_in_cinema = true
export (bool) var show_chair = true
export (bool) var can_be_sat_down = true
export (bool) var should_boost_seat = false
var unique_id

signal player_seated
signal player_stood_up

func _ready():
	add_to_group("Interactable")
	self.connect("player_seated", get_owner(), "player_seated")
	self.connect("player_stood_up", get_owner(), "player_stood_up")
	_hide_silhouette()
	$"Chair".visible = show_chair


func _enter_tree():
	unique_id = get_name()


func interacted():
	if not can_be_sat_down or not $interactTimer.is_stopped(): return

	if Globals.is_show_mainhub_start_screen: return
	
	for p in get_tree().get_nodes_in_group("Player"):
		if p.is_player_input_disabled: return

		_manip_cinema_screen(p.is_seated)
		p.global_position.x = global_position.x
		p.is_seated = not p.is_seated
		boost_seat(p.is_seated)
		_hide_silhouette()
		$interactTimer.start()




func boost_seat( var is_player_seated: bool):
	if not should_boost_seat: return
	$boosterAnimPlayer.play("boost_seat") if is_player_seated else $boosterAnimPlayer.play_backwards("boost_seat")


func _manip_cinema_screen( var is_player_seated: bool):
	if not is_in_cinema: return
	if is_player_seated:
		emit_signal("player_seated")
	else:
		emit_signal("player_stood_up")


func _show_silhouette():
	$"InteractArrow".show()
	pass
	
func _hide_silhouette():
	$"InteractArrow".hide()
	pass




















func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		pass
