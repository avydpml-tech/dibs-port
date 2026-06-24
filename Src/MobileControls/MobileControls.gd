extends CanvasLayer

const STICK_RADIUS = 80.0
const DEAD_ZONE = 0.2
const UP_THRESHOLD = -0.5
const DOWN_THRESHOLD = 0.5

var left_stick_origin := Vector2.ZERO
var left_touch_index := -1
var left_active := false

var right_stick_origin := Vector2.ZERO
var right_touch_index := -1
var right_active := false

var fire_pressed := false
var reload_pressed := false
var tap_touch_index := -1

onready var left_knob  = $LeftStick/Knob
onready var right_knob = $RightStick/Knob
onready var fire_btn   = $FireButton
onready var reload_btn = $ReloadButton

var _actions_pressed := {}


func _ready():
	var screen = OS.get_screen_size()
	$LeftStick.rect_position    = Vector2(80, screen.y - 280)
	$RightStick.rect_position   = Vector2(screen.x - 280, screen.y - 280)
	$FireButton.rect_position   = Vector2(screen.x - 210, screen.y - 420)
	$ReloadButton.rect_position = Vector2(screen.x - 370, screen.y - 260)

	left_stick_origin  = $LeftStick.rect_position + Vector2(100, 100)
	right_stick_origin = $RightStick.rect_position + Vector2(100, 100)

	set_process_input(true)


func _input(event):
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch):
	var pos = event.position
	var screen = OS.get_screen_size()

	if event.pressed:
		# Кнопки проверяем первыми через get_global_rect()
		if fire_btn.get_global_rect().has_point(pos):
			fire_pressed = true
			_press_action("ui_flashlight")
			return

		if reload_btn.get_global_rect().has_point(pos):
			reload_pressed = true
			_press_action("ui_r")
			return

		# Левый стик — нижняя левая зона
		if not left_active and pos.x < screen.x * 0.35 and pos.y > screen.y * 0.5:
			left_active = true
			left_touch_index = event.index
			left_stick_origin = pos
			$LeftStick.rect_position = pos - Vector2(100, 100)
			return

		# Правый стик — нижняя правая зона
		if not right_active and pos.x > screen.x * 0.65 and pos.y > screen.y * 0.5:
			right_active = true
			right_touch_index = event.index
			right_stick_origin = pos
			$RightStick.rect_position = pos - Vector2(100, 100)
			return

		# Всё остальное = диалог
		tap_touch_index = event.index
		_press_action("dialogic_default_action")

	else:
		if event.index == left_touch_index:
			left_active = false
			left_touch_index = -1
			_release_left_actions()
			_reset_left_knob()

		if event.index == right_touch_index:
			right_active = false
			right_touch_index = -1
			_release_right_actions()
			_reset_right_knob()

		if event.index == tap_touch_index:
			tap_touch_index = -1
			_release_action("dialogic_default_action")

		if fire_pressed:
			fire_pressed = false
			_release_action("ui_flashlight")

		if reload_pressed:
			reload_pressed = false
			_release_action("ui_r")


func _handle_drag(event: InputEventScreenDrag):
	if event.index == left_touch_index:
		_update_left_stick(event.position)
	if event.index == right_touch_index:
		_update_right_stick(event.position)


func _update_left_stick(pos: Vector2):
	var delta = pos - left_stick_origin
	var dist  = delta.length()
	var dir   = delta.normalized() if dist > 1 else Vector2.ZERO

	if dist > STICK_RADIUS:
		left_knob.rect_position = dir * STICK_RADIUS + Vector2(60, 60)
	else:
		left_knob.rect_position = delta + Vector2(60, 60)

	if dir.x < -DEAD_ZONE:
		_press_action("kb_left")
		_release_action("kb_right")
	elif dir.x > DEAD_ZONE:
		_press_action("kb_right")
		_release_action("kb_left")
	else:
		_release_action("kb_left")
		_release_action("kb_right")

	if dir.y < UP_THRESHOLD:
		_press_action("ui_up")
		_release_action("ui_interact")
	elif dir.y > DOWN_THRESHOLD:
		_press_action("ui_interact")
		_release_action("ui_up")
	else:
		_release_action("ui_up")
		_release_action("ui_interact")


func _release_left_actions():
	_release_action("kb_left")
	_release_action("kb_right")
	_release_action("ui_up")
	_release_action("ui_interact")


func _reset_left_knob():
	left_knob.rect_position = Vector2(60, 60)
	$LeftStick.rect_position = left_stick_origin - Vector2(100, 100)


func _update_right_stick(pos: Vector2):
	var delta = pos - right_stick_origin
	var dist  = delta.length()
	var dir   = delta.normalized() if dist > 1 else Vector2.ZERO

	if dist > STICK_RADIUS:
		right_knob.rect_position = dir * STICK_RADIUS + Vector2(60, 60)
	else:
		right_knob.rect_position = delta + Vector2(60, 60)

	if dir.x < -DEAD_ZONE:
		_press_action("aim_left")
		_release_action("aim_right")
	elif dir.x > DEAD_ZONE:
		_press_action("aim_right")
		_release_action("aim_left")
	else:
		_release_action("aim_left")
		_release_action("aim_right")

	if dir.y < -DEAD_ZONE:
		_press_action("aim_up")
		_release_action("aim_down")
	elif dir.y > DEAD_ZONE:
		_press_action("aim_down")
		_release_action("aim_up")
	else:
		_release_action("aim_up")
		_release_action("aim_down")


func _release_right_actions():
	_release_action("aim_left")
	_release_action("aim_right")
	_release_action("aim_up")
	_release_action("aim_down")


func _reset_right_knob():
	right_knob.rect_position = Vector2(60, 60)
	$RightStick.rect_position = right_stick_origin - Vector2(100, 100)


func _press_action(action: String):
	if _actions_pressed.get(action, false):
		return
	_actions_pressed[action] = true
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = true
	Input.parse_input_event(ev)


func _release_action(action: String):
	if not _actions_pressed.get(action, false):
		return
	_actions_pressed[action] = false
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = false
	Input.parse_input_event(ev)
