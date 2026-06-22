extends StaticBody2D

export (String) var signal_id = "boss_door"
export (bool) var is_open = true

onready var origin_pos = global_position

func _init():
	add_to_group(signal_id)

func _ready():
	_open_or_close_door()

func _interacted():
	_open_or_close_door()
	print("goobage")


func _open_or_close_door():
	var new_pos = origin_pos + Vector2(0, - 300) if is_open else origin_pos

	$Tween.interpolate_property(self, "global_position", global_position, new_pos, 0.7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

	is_open = not is_open
