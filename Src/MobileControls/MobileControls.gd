extends CanvasLayer

const STICK_RADIUS = 80.0
const DEAD_ZONE = 0.2

# Игровое разрешение
const GAME_W = 1280.0
const GAME_H = 720.0

# Левый стик (динамический)
var left_stick_origin := Vector2.ZERO
var left_touch_index := -1
var left_active := false

# Правый стик (фиксированный)
var right_stick_origin := Vector2.ZERO
var right_touch_index := -1
var right_active := false

# Кнопки
var fire_touch_index := -1
var reload_touch_index := -1
var tap_touch_index := -1

var _actions_pressed := {}

var _left_knob   = null
var _right_knob  = null
var _fire_btn    = null
var _reload_btn  = null
var _menu_btn    = null

# Начальная позиция левого стика (для сброса)
var _left_stick_home := Vector2.ZERO
var _right_stick_home := Vector2.ZERO


func _ready():
	yield(get_tree(), "idle_frame")

	_left_knob  = get_node("LeftStick/Knob")
	_right_knob = get_node("RightStick/Knob")
	_fire_btn   = get_node("FireButton")
	_reload_btn = get_node("ReloadButton")
	_menu_btn   = get_node("MenuButton")

	# Левый стик — нижний левый угол
	_left_stick_home = Vector2(60, GAME_H - 220)
	get_node("LeftStick").rect_position = _left_stick_home

	# Правый стик — нижний правый угол (фиксированный)
	_right_stick_home = Vector2(GAME_W - 260, GAME_H - 220)
	get_node("RightStick").rect_position = _right_stick_home

	# Кнопка выстрела — над правым стиком
	get_node("FireButton").rect_position = Vector2(GAME_W - 175, GAME_H - 370)

	# Кнопка перезарядки — левее правого стика
	get_node("ReloadButton").rect_position = Vector2(GAME_W - 360, GAME_H - 230)

	# Пауза — правый верхний угол
	get_node("MenuButton").rect_position = Vector2(GAME_W - 110, 20)

	left_stick_origin  = _left_stick_home + Vector2(100, 100)
	right_stick_origin = _right_stick_home + Vector2(100, 100)

	set_process_input(true)


func _input(event):
	if _left_knob == null:
		return
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch):
	var pos = event.position

	if event.pressed:
		# Пауза
		if _menu_btn.get_global_rect().has_point(pos):
			_press_action("ui_pause")
			return

		# Выстрел
		if _fire_btn.get_global_rect().has_point(pos):
			fire_touch_index = event.index
			_press_action("ui_flashlight")
			return

		# Перезарядка
		if _reload_btn.get_global_rect().has_point(pos):
			reload_touch_index = event.index
			_press_action("ui_r")
			return

		# Правый стик (прицел) — правая половина нижней зоны
		if not right_active and pos.x > GAME_W * 0.55 and pos.y > GAME_H * 0.45:
			right_active = true
			right_touch_index = event.index
			right_stick_origin = _right_stick_home + Vector2(100, 100)
			return

		# Левый стик (движение) — левая половина нижней зоны, динамический
		if not left_active and pos.x < GAME_W * 0.45 and pos.y > GAME_H * 0.45:
			left_active = true
			left_touch_index = event.index
			left_stick_origin = pos
			get_node("LeftStick").rect_position = pos - Vector2(100, 100)
			return

		# Тап в остальных зонах = ui_touch (диалоги)
		tap_touch_index = event.index
		_press_action("ui_touch")

	else:
		if _menu_btn.get_global_rect().has_point(pos):
			_release_action("ui_pause")

		if event.index == fire_touch_index:
			fire_touch_index = -1
			_release_action("ui_flashlight")

		if event.index == reload_touch_index:
			reload_touch_index = -1
			_release_action("ui_r")

		if event.index == left_touch_index:
			left_active = false
			left_touch_index = -1
			_release_left_actions()
			_reset_left_knob()

		if event.index == right_touch_index:
			right_active = false
			right_touch_index = -1
			_release_right_actions()

		if event.index == tap_touch_index:
			tap_touch_index = -1
			_release_action("ui_touch")


func _handle_drag(event: InputEventScreenDrag):
	if _left_knob == null:
		return
	if event.index == left_touch_index:
		_update_left_stick(event.position)
	if event.index == right_touch_index:
		_update_right_stick(event.position)


func _update_left_stick(pos: Vector2):
	var delta = pos - left_stick_origin
	var dist  = delta.length()
	var dir   = delta.normalized() if dist > 1 else Vector2.ZERO

	if dist > STICK_RADIUS:
		_left_knob.rect_position = dir * STICK_RADIUS + Vector2(60, 60)
	else:
		_left_knob.rect_position = delta + Vector2(60, 60)

	# Горизонталь — движение
	if dir.x < -DEAD_ZONE:
		_press_action("kb_left")
		_release_action("kb_right")
	elif dir.x > DEAD_ZONE:
		_press_action("kb_right")
		_release_action("kb_left")
	else:
		_release_action("kb_left")
		_release_action("kb_right")

	# Вертикаль — вверх=прыжок, вниз=взаимодействие
	if dir.y < -0.5:
		_press_action("ui_up")
		_release_action("ui_down")
	elif dir.y > 0.5:
		_press_action("ui_down")
		_release_action("ui_up")
	else:
		_release_action("ui_up")
		_release_action("ui_down")


func _release_left_actions():
	_release_action("kb_left")
	_release_action("kb_right")
	_release_action("ui_up")
	_release_action("ui_down")


func _reset_left_knob():
	_left_knob.rect_position = Vector2(60, 60)
	get_node("LeftStick").rect_position = _left_stick_home


func _update_right_stick(pos: Vector2):
	var delta = pos - right_stick_origin
	var dist  = delta.length()
	var dir   = delta.normalized() if dist > 1 else Vector2.ZERO

	if dist > STICK_RADIUS:
		_right_knob.rect_position = dir * STICK_RADIUS + Vector2(60, 60)
	else:
		_right_knob.rect_position = delta + Vector2(60, 60)

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
