extends TextureProgress

export (float) var time_to_transition = 1

var pressed_up_timer = Timer.new()
var is_pressing_up = false









signal go_to_chamber_allowed


func _input(event):
	if Globals.get_player().player_state != "afterglow":
		return

	if event.is_action_pressed("ui_up"):
		pressed_up_timer.start(time_to_transition - pressed_up_timer.time_left)
		is_pressing_up = true
		if $fadeAnimation.is_playing() == false:
			modulate = "70ffffff"
		ScreenManager.slow_fade()
			
	elif event.is_action_released("ui_up"):
		pressed_up_timer.start(time_to_transition * (value / 100))
		is_pressing_up = false
		if $fadeAnimation.is_playing() == false:
			modulate = "27ffffff"
		ScreenManager.normal_speed_fade()


func _ready():
	value = 0
	modulate = "27ffffff"
	add_child(pressed_up_timer)
	pressed_up_timer.set_one_shot(true)
	pressed_up_timer.set_timer_process_mode(Timer.TIMER_PROCESS_IDLE)
	pressed_up_timer.connect("timeout", self, "committed_to_chamber")
	$pop.connect("finished", self, "queue_free_arrow")


func _process(delta):
	if is_pressing_up:
		value = (time_to_transition - pressed_up_timer.time_left) / time_to_transition * 100
	else:
		value = pressed_up_timer.time_left / time_to_transition * 100


func committed_to_chamber():
	if value >= 95:
		emit_signal("go_to_chamber_allowed")
		value = 100
		if $fadeAnimation.is_playing() == false:
			$fadeAnimation.play("fade")
		
		Globals.get_player().can_go_to_chamber = true
	ScreenManager.normal_speed_fade()

func queue_free_arrow():
	queue_free()
	ScreenManager.normal_speed_fade()
