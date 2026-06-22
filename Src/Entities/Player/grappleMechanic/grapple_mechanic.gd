






















extends CanvasLayer


signal grappled_free
signal grapple_to_saucy
signal player_won

export (bool) var enable_creatures = true
export (bool) var allow_grapple = true
export (bool) var use_local_debug = false
export (int) var bored_mode_rip_enjoy_amount = 10


export (String) var entity_inst = null
export (Array, String) var disable_tentacle_for = ["f_koubold", "f_grabbed", "f_wolf", "boss"]
export (Resource) var enemy_heart

var rand = int(rand_range(1, 4))
var damage_to_Nonplayer: int = 0
var did_player_win: bool = false

onready var player
var mon_name: String = ""



func _input(event):
	if event.is_action_pressed("ui_z"):
		grapple_finished("player_won")


func _ready():
	player = get_parent()
	
	if player.is_tangled:
		grapple_finished("saucy_time")
	if not player.is_connected("stamina_depleted", self, "check_rip_or_saucy"):
		player.connect("stamina_depleted", self, "check_rip_or_saucy")

	if is_instance_valid(entity_inst):
		mon_name = entity_inst.entity_name

	$player.position = $playerOrigin.position
	
	rand_position("winArea", "winPos")
		
	if mon_name in disable_tentacle_for:
		$GrappleAnimation.global_position.y -= 1000
	
	if not mon_name in ["f_koubold", "f_wolf", "boss"]:
		$Audio / AudioStreamPlayer.autoplay = true
		$Audio / AudioStreamPlayer.play()


	if player.is_player_autosauce:
		call_deferred("rip_or_saucy", true)

	spawn_enemy_heart()
	SettingsManager.connect("exploration_mode_set", self, "exploration_mode_changed")


func _process(_delta):
	if get_parent().being_saucied:
		call_deferred("free")

	if not mon_name in ["f_grabbed", "f_wolf", "boss"] and not SettingsManager.is_bored_mode:
		reduce_player_stamina(_delta)



func grapple_finished(finish_condition):
	match finish_condition:
		"player_won":
			if not is_connected("player_won", get_parent(), "_on_free_grapple"):
				connect("player_won", get_parent(), "_on_free_grapple")
			emit_signal("player_won")


		"break_free":
			did_player_win = false
			if not is_connected("grappled_free", get_parent(), "_on_free_grapple"):
				connect("grappled_free", get_parent(), "_on_free_grapple", [did_player_win])
			emit_signal("grappled_free")
		

		"break_free_no_decrease_stamina":
			did_player_win = false
			if not is_connected("grappled_free", get_parent(), "_on_free_grapple"):
				connect("grappled_free", get_parent(), "_on_free_grapple", [did_player_win, false])
			emit_signal("grappled_free")
			

		"saucy_time":
			if not is_connected("grapple_to_saucy", get_parent(), "_on_grapple_to_saucy"):
				connect("grapple_to_saucy", get_parent(), "_on_grapple_to_saucy")
			emit_signal("grapple_to_saucy")
			player.is_grappled = true

	
	call_deferred("free")





func check_rip_or_saucy():
	if SettingsManager.is_bored_mode:
		return
	else:
		rip_or_saucy()


func rip_or_saucy(insta_saucy = false):
	if insta_saucy:
		grapple_finished("saucy_time")

	elif mon_name == "boss":
		grapple_finished("player_won")

	elif player.current_health > 0:
		player.current_health -= 1
		player.get_node("Audio/clothing_rip").play()
		grapple_finished("break_free")

	elif not is_instance_valid(entity_inst):
		grapple_finished("break_free")
		
	elif player.current_health <= 0 and mon_name == "f_grabbed":
		grapple_finished("break_free")
		
	elif allow_grapple:
		grapple_finished("saucy_time")


func _on_winArea_body_entered(body):
	if body.get_name() == "player":
		grapple_finished("player_won")


func _creature_dead():
	connect("grappled_free", get_parent(), "_on_free_grapple")
	emit_signal("grappled_free")
	call_deferred("free")


func reduce_player_stamina(delta):
	Globals.get_player().decrease_stamina(delta * 8)


func _on_staminaSkip_button_down():
	grapple_finished("player_won")


func spawn_enemy_heart():
	if mon_name in ["f_koubold", "f_wolf", "boss"]:
		return

	var heart_inst = enemy_heart.instance()
	add_child(heart_inst)
	rand_position(heart_inst.get_name(), "heartPos")
	




func rand_position( var node_name: String = "", var position_name = ""):

	if get_node(node_name) == null:
		return

	if mon_name == "f_wolf":
		$winArea.global_position = $winPos / wolfWinPos.global_position
		$blueHeart.hide()
		return
	
	rand = int(rand_range(1, 4))
	
	var position_string = position_name + "/" + position_name + str(rand)
	var win_pos = get_node(position_string)
	
	get_node(node_name).global_position = win_pos.global_position


func exploration_mode_changed():
	if SettingsManager.is_exploration_mode:
		grapple_finished("player_won")
