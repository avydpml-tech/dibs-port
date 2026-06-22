extends Area2D

export (bool) var disable_collision = false
export (float) var enlarged_cursor_scale = 0
export (float) var additional_delay = 1

onready var anim_player = $AnimationPlayer
onready var crosshair = $crosshair

var player = null
var bullet_spread: float = 0
var default_cursor_scale: float = 0







func _enter_tree():
	player = get_parent().get_parent()

func _ready():
	default_cursor_scale = crosshair.scale.x
	$CollisionShape2D.disabled = disable_collision

	if not player.is_connected("player_state_changed", self, "_player_state_changed"):
		player.connect("player_state_changed", self, "_player_state_changed")
	if not player.is_connected("player_dir_changed", self, "_player_dir_changed"):
		player.connect("player_dir_changed", self, "_player_dir_changed")

	if not Pause.is_connected("game_unpaused", self, "_is_autowalk"):
		Pause.connect("game_unpaused", self, "_is_autowalk")

	setup_accuracy_reticle()
	_is_autowalk()


func _process(_delta):
	set_reticle_position()
	_set_ammo_count()
	start_accuracy_reticle_animation()

	call_deferred("show") if (player.player_state == "aim") and ( not get_tree().paused) else hide()

	if get_tree().paused:
		_is_autowalk()

func _player_state_changed():
	_is_autowalk()


func _player_dir_changed():
	_is_autowalk()



func set_reticle_position():
	if Globals.is_using_controller:
		global_position = player.reticle_pos.get_global_transform_with_canvas().origin
	else:
		global_position = get_global_mouse_position()


func _set_ammo_count():
	if player.player_state == "aim":
		$Label.set_text(str(player.ammo_count))


func _is_autowalk():
	if player.player_state == "aim":
		CursorManager.set_cursor("dot")
	
	elif get_tree().paused or not player.player_state in ["jump", "fall", "run"]:
		CursorManager.set_cursor("scoped")

	
	elif Globals.is_show_mainhub_start_screen:
		CursorManager.set_cursor("scoped")

	elif player.one_handed_movement:
		CursorManager.set_cursor("dot")
		match player.dir:
			"left": CursorManager.set_cursor("walk_left")
			"right": CursorManager.set_cursor("walk_right")

	else:
		CursorManager.set_cursor("scoped")




var has_reverted_to_idle: bool = true
func start_accuracy_reticle_animation():
	if player.player_state == "aim":
		if not anim_player.is_playing() and has_reverted_to_idle:
			has_reverted_to_idle = false
			anim_player.play("accuracy")
	elif not has_reverted_to_idle:
		anim_player.seek(1.9, true)
		anim_player.stop()
		has_reverted_to_idle = true







func setup_accuracy_reticle():
	var wait_time = player.bullet_spread_timer.wait_time
	var animation = $AnimationPlayer.get_animation("accuracy")
	
	var idx = animation.find_track("crosshair:scale")
	
	animation.set_length(wait_time + additional_delay)
	animation.track_set_key_value(idx, 0, Vector2(enlarged_cursor_scale, enlarged_cursor_scale))
