extends Area2D

export (Array, PackedScene) var options_packed_scenes
export (bool) var is_start_disabled: = false

var player

func _ready():
	$CanvasLayer / Control / HBoxContainer.set("custom_constants/separation", 30)
	add_interact_options()
	if is_start_disabled:
		disable_menu()


func disable_menu():
	$ExitArea.monitoring = false
	monitoring = false


func enable_menu():
	$ExitArea.monitoring = true
	monitoring = true


func add_interact_options():
	for i in options_packed_scenes:
		var inst = i.instance()
		inst.call_deferred("set_owner", self)
		$CanvasLayer / Control / HBoxContainer.add_child(inst)
		inst.connect("option_selected", self, "_on_hide_option_selected")


func _on_HandfanMenu_body_entered(body):
	if body is PlayerChar and not $CanvasLayer / Control.visible:
		$AnimationPlayer.play("fade")


func _on_ExitArea_body_exited(body):
	if body is PlayerChar and $CanvasLayer / Control.visible:
		$AnimationPlayer.play_backwards("fade")


func _on_hide_option_selected():
	$AnimationPlayer.play_backwards("fade")
