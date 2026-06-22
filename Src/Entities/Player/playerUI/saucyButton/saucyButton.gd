extends Node






export (String, "koubold", "wolf") var saucy_anim

var is_saucied: bool = false

signal player_coom

func _ready():
	self.visible = false
	$circle.scale = Vector2(0.214, 0.214)
	saucy_start()


func _input(event):
	if is_saucied and event.is_action_pressed("ui_controller_accept"):
		if Globals.get_player().player_state == "idle":
			_on_coomButton_pressed()


func saucy_start():
	_on_playerChar_coom_ready()
	$fullCircleFadeIn.seek(0, true)
	$fullCircleFadeIn.stop()
	$glowShader.seek(0, true)
	$glowShader.stop()
	Globals.get_player().is_woof_or_koubold = true


func _on_coomButton_pressed():
	var player = Globals.get_player()
	player.is_saucied_with_koubold = true

	player._play_saucy_anim("koubold")
	player.show_saucy_sprite(true)
	player.mon_grappled_name = "koubold"

	return

	
	
	

	

	
	
	
	


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
	
