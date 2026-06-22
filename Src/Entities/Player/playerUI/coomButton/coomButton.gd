extends Node




signal player_coom

var is_saucied: bool = false

func _ready():
	$circle.scale = Vector2(0.214, 0.214)


func _input(event):
	if is_saucied and event.is_action_pressed("ui_controller_accept"):
		_on_coomButton_pressed()


func saucy_start():
	_on_playerChar_coom_ready()
	$fullCircleFadeIn.seek(0, true)
	$fullCircleFadeIn.stop()
	$glowShader.seek(0, true)
	$glowShader.stop()
	is_saucied = true


func _on_coomButton_pressed():
	if not is_connected("player_coom", Globals.get_player(), "turn_continue_saucy_false"):
		if self.connect("player_coom", Globals.get_player(), "turn_continue_saucy_false") != OK:
			print(self, ": player_coom signal not connecting to turn_continue_saucy_false")

	emit_signal("player_coom")

	self.visible = false
	
	saucy_start()
	is_saucied = false
	


func _on_coomButton_mouse_entered():
	$AnimationPlayer.play("mouse_entered")


func _on_coomButton_mouse_exited():
	var animation = $AnimationPlayer.get_animation("mouse_exited")
	
	var property_name = "circle:scale"
	var track = animation.find_track(property_name)
	var last_keyframe = animation.track_get_key_count(track) - 1
	
	animation.track_set_key_value(track, 0, $circle.scale)
	
	$AnimationPlayer.play("mouse_exited")
	

func _on_playerChar_coom_ready():
	if not $fullCircleFadeIn.is_playing():
		$fullCircleFadeIn.play("coom_ready")
		$glowShader.play("coom_ready")
















