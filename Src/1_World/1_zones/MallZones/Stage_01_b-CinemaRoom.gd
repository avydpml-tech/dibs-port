extends Stage

export (bool) var kb_controls = false

var cinema_tapes: Array = Achievements.get_collected_tapes()
var cinema_select_index: int = 0 setget _set_cinema_select_index
onready var cinema_screen = $Screen / cinemaScreen
onready var player = Globals.get_player()

func _ready():
	_set_stage_music_if_no_cinema_anim()
	_generic_ready()
	_check_disabled_tapes()
	_set_player_camera_limits(true, 500, 0, 1500, 800)
	_set_signals()


func _set_stage_music_if_no_cinema_anim():
	if Achievements.get_num_of_cinema_tapes() != 0:
		stage_music = "m_space_jazz"


func _set_signals():
	if not SettingsManager.is_connected("sfw_mode_set", self, "_check_disabled_tapes"):
		SettingsManager.connect("sfw_mode_set", self, "_check_disabled_tapes")


func _input(event):
	if kb_controls and player.is_seated:
		if event.is_action_pressed("ui_right"):
			_next_tape()
		elif event.is_action_pressed("ui_left"):
			_prev_tape()

		if event.is_action_pressed("ui_space"):
			_turn_on_or_off_cinema_tapes()

	if event.is_action_pressed("ui_up") and player.is_seated:
		_turn_on_or_off_cinema_tapes(false)
		screen_anim.play_backwards("turn_off_screen")
		player.is_seated = false
	
	if event.is_action_pressed("ui_4"):
		Achievements.auto_complete_cinema()
		_check_disabled_tapes()
		cinema_tapes = Achievements.get_collected_tapes()


func _set_cinema_select_index(index):
	cinema_select_index = index
	
	
	if cinema_select_index > cinema_tapes.size() - 1:
		cinema_select_index = 0
	elif cinema_select_index < 0:
		cinema_select_index = cinema_tapes.size() - 1




func _check_disabled_tapes():
	for thumbnail in get_tree().get_nodes_in_group("CinemaTape"):
		thumbnail.disabled = false if cinema_tapes.has(thumbnail.cinema_name_nsfw) else true
		thumbnail._ready()

func player_seated():
	_turn_on_or_off_cinema_tapes(false)
	screen_anim.play_backwards("turn_off_screen")


func player_stood_up():
	screen_anim.play("turn_off_screen")





func play_tape(tape_name: String):
	screen_anim.play("transition_to_anim")

	var anim_names_arr = cinema_screen.get_sprite_frames().get_animation_names()
	if not tape_name in anim_names_arr:
		print("Cinema: Tape \"", tape_name, "\" not found in animations.")
		return

	print("Cinema: Playing ", tape_name)
	cinema_screen.play(tape_name)


func _turn_on_or_off_cinema_tapes(boolean = null):
	cinema_screen.visible = not cinema_screen.visible if boolean == null else boolean


func _next_tape():
	self.cinema_select_index += 1
	var tape_name: String = cinema_tapes[cinema_select_index]
	play_tape(tape_name)


func _prev_tape():
	self.cinema_select_index -= 1
	var tape_name: String = cinema_tapes[cinema_select_index]
	play_tape(tape_name)


func change_lighting(new_lighting):
	emit_signal("new_time", new_lighting)







onready var screen_anim = $Screen / screenAnim

func _on_backArrow_pressed():
	screen_anim.play("show_tapes_selection")
	_turn_on_or_off_cinema_tapes()




func _on_screenAnim_animation_finished(anim_name):
	if anim_name == "turn_off_screen" and player.is_seated:
		screen_anim.play("show_tapes_selection")


onready var anim_set_player = $Screen / AnimationSets / AnimationPlayer
onready var anim_set_label = $Screen / AnimSetLabel


func _on_nextAnimSetButton_pressed():
	anim_set_player.play("next_set")
	anim_set_label.set_text("2 / 2")


func _on_prevAnimSetButton_pressed():
	anim_set_player.play("prev_set")
	anim_set_label.set_text("1 / 2")


func _on_self_pressed():
	pass
