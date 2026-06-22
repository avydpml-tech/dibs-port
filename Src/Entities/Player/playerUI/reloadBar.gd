extends TextureProgress

var player = null

func _enter_tree():
	player = get_parent()

func _ready():
	hide()
	pass
	
func _process(_delta):
	show() if player.player_state == "reload" else hide()
	
	assign_values()
	show_combine_ammo()

func assign_values():
	var reload_time = player.time_to_reload
	var reload_timer = player.reload_timer
	
	value = (reload_time - reload_timer.time_left) / reload_time * 100


func show_combine_ammo():
	if (player.is_in_reload_combine_threshold() and player.can_combine_ammo)\
	or SettingsManager.is_auto_combine_ammo_mode:
		get_node("combineAmmoIcon").show()
	else:
		get_node("combineAmmoIcon").hide()
