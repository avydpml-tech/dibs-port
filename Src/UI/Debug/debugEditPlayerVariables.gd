extends VBoxContainer

var player

func _ready():
	set_deferred("player", Globals.get_player())
	call_deferred("_set_local_values")


func _set_local_values():
	$runSpeedInputBox.value = player.max_speed

func _on_runSpeedInputBox_value_changed(value):
	player.set_max_speed(value)
	pass
