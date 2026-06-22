extends Stage

var player
var array_index: int = 0 setget set_array_index
var spawner
var creature_list

func _ready():
	_generic_ready()
	SoundManager.stop_music()
	spawner = $overview / CanvasLayer / creatureSpawner
	player = Globals.get_player()


	player.can_go_to_chamber = true
	if player.coom_count >= player.coom_capacity:
		player.is_tangled = true
	creature_list = player.who_saucied

	if player.is_tangled:
		spawner.update_creature(creature_list[0])
		player.global_position = $doors_transitions / tangleStartPos.global_position
	else:
		spawner.disable()



func set_array_index(value):
	array_index = value

	
	if array_index > len(creature_list) - 1: array_index = 0
	if array_index < - len(creature_list) + 1: array_index = 0
	
	var creature_name = creature_list[array_index]

	if self.has_node("overview/CanvasLayer/creatureSpawner"):
		spawner.update_creature(creature_name)
		


func _input(event):
	if not player.is_tangled:
		if self.has_node("overview/CanvasLayer/creatureSpawner"):
			spawner.disable()
		return
		
	if Input.is_action_just_released("ui_up"):
		self.array_index += - 1
	if Input.is_action_just_released("ui_down"):
		self.array_index += 1
	if Input.is_action_just_released("ui_space") or Input.is_action_just_released("ui_controller_accept")\
	or Input.is_action_just_released("ui_accept"):
		if self.has_node("overview/CanvasLayer/creatureSpawner"):
			spawner.spawn_creature_in_chamber(creature_list[array_index], true)
			spawner.disable()
			$exclaimPopup.emitting = true
			$whistle.play()

	if Input.is_action_just_pressed("ui_j"):
		creature_list = player.who_saucied
		
