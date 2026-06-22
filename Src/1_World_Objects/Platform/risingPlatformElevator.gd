





extends Interactable

export (int) var end_position = 0
export (bool) var disable_engine_sound = false

var rise_value = 0 setget rise_value_changed
var start_position = Vector2(0, 0)
var player = null

func _ready():
	start_position = get_global_position()
	player = Globals.get_player()
	if disable_engine_sound:
		turn_on_lights()
		turn_on_side_lights()

func _physics_process(delta):
	if at_start_or_end_point():
		rise_value = 0
	global_position.y -= delta * rise_value
	global_position.y = clamp(global_position.y, end_position, start_position.y)

	if end_position > start_position.y:
		print_debug("ERROR: ", self.get_name(), " start_position is greater than end_position")
	
func rise_value_changed(new_value):
	if new_value == 0:
		if start_position.y <= global_position.y:
			player.disable_snap_to_floor()
	rise_value = new_value

func at_start_or_end_point() -> bool:
	
	
	if start_position.y <= global_position.y or global_position.y <= end_position:
		$CollisionShape2D.call_deferred("set_disabled", false)
		$Area2D2 / CollisionShape2D.call_deferred("set_disabled", false)
		return true
	return false
	

func turn_on_lights():
	if not bodies_area.empty():
		$AnimationPlayer.play("show_lights")
	else:
		$AnimationPlayer.play_backwards("show_lights")
	
func turn_on_side_lights():
	$flooroff.show() if bodies_area.empty() else $flooroff.hide()
	
	
	
var bodies_area = []
var rise = false
func interacted():
	if not _is_player_on_platform(): return

	if rise_value == 0:
		turn_on_lights()
		turn_on_side_lights()
		
		if not rise:
			
			
			player.disable_snap_to_floor()
		rise = not rise

		if at_start_or_end_point():
			$click_audio.play()
			raise_platform() if rise else lower_platform()

	if not rise:
		player.snap_to_floor()
	

func raise_platform():
	global_position.y += - 5
	self.rise_value = 500
func lower_platform():
	global_position.y += 5
	rise = false
	self.rise_value = - 500

func _is_player_on_platform() -> bool:
	for body in bodies_area:
		if Globals._is_player(body):
			return true
	return false



func _on_Area2D_body_entered(body):
	if Globals._is_player(body) or body.get_class() == "Nonplayer":
		if not bodies_area.has(body):
			if Globals._is_player(body):
				$click_audio.play()
			bodies_area.append(body)
		turn_on_side_lights()
		


func _on_Area2D2_body_exited(body):
	if Globals._is_player(body) or body.get_class() == "Nonplayer":
		if Globals._is_player(body):
			lower_platform()
		bodies_area.erase(body)

	if bodies_area.empty():
		$CollisionShape2D.call_deferred("set_disabled", true)
		$Area2D2 / CollisionShape2D.call_deferred("set_disabled", true)
		lower_platform()
		player.disable_snap_to_floor()

		turn_on_lights()
		turn_on_side_lights()


func _player_entered():
	pass
func _player_exited():
	pass
