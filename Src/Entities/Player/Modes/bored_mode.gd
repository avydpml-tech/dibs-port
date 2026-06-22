extends Node2D



var disabled: bool = false
var player = null



func _ready():
	player = get_parent()
	SettingsManager.connect("bored_mode_set", self, "set_bored_mode_disable")
	player.connect("player_fired", self, "mox_enjoy_shooting")
	disabled = not SettingsManager.is_bored_mode


func _process(delta):
	if disabled: return

	if player.player_state == "idle":
		player.decrease_stamina(0.17)
	else:
		player.decrease_stamina(0.1)


func set_bored_mode_disable():
	disabled = not SettingsManager.is_bored_mode


func mox_enjoy_shooting():
	if SettingsManager.is_bored_mode:
		player.add_stamina(3)