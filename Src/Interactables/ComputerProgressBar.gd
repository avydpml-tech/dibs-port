extends TextureProgress


export (float) var timer = 1
export (String) var call_method = ""
signal progress_finished

var is_interacted: bool = false

func _ready():
	$Timer.wait_time = timer
	$Timer.stop()


func interacted():
	is_interacted = true
	$Timer.start()


func _process(delta):
	value = (timer - $Timer.time_left) / timer * 100
	visible = not $Timer.is_stopped()


func stop_progress():
	is_interacted = false
	$Timer.stop()


func _on_ProgressBar_value_changed(value: float):
	if value > 96 and is_interacted:
		get_owner().call_deferred(call_method)
