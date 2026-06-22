extends Stage

export (float) var train_time = 1

func _ready():
	_generic_ready()
	$TrainTimer.start(train_time)
	$ParallaxBG.play("start_train")
	$ParallaxLights.play("start_parallax_light")
	$Audio / Train.play()
	
	if not Globals.is_in_labs:
		$doors_transitions / exitTrain.scene_path_to_load = "res://Src/1_World/1_zones/RightSuites/Park/Stage-Labs.tscn"
		Globals.is_in_labs = true
	else:
		$doors_transitions / exitTrain.scene_path_to_load = "res://Src/1_World/1_zones/RightSuites/Park/Stage-TrainStation.tscn"
		Globals.is_in_labs = false


func _process(delta):
	$TrainTrinkets / trainProgress.value = (($TrainTimer.wait_time - $TrainTimer.time_left) / $TrainTimer.wait_time) * 100


func _on_ParallaxLights_animation_finished(anim_name: String):
	if anim_name == "start_parallax_light":
		$ParallaxLights.play("very_fast_light")


func _on_TrainTimer_timeout():
	$doors_transitions / exitTrain.door_active = true
	$TrainTrinkets / Lamp2.show()
	$ParallaxLights.play("slow_down_parallax_light")
	$Audio / EndBeep.play()
	$Audio / TrainSlowDown.play()
	$Audio / Train.stop()


func _on_TrainDoorEnterance_body_entered(body: Node):
	if body.get_name() == "playerChar":
		$TrainDoor / TrainDoorOutline / AnimationPlayer.play("fade_in")

func _on_TrainDoorExit_body_exited(body: Node):
	if body.get_name() == "playerChar":
		$TrainDoor / TrainDoorOutline / AnimationPlayer.play_backwards("fade_in")
