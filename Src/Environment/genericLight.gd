extends Light2D

var state_switcher: = true
export (bool) var is_on_start_fade = false

onready var origin_energy = energy

func _ready():
	if is_on_start_fade:
		fade()


func fade():
	var new_energy = 0 if state_switcher else origin_energy

	var tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(self, "energy", energy, new_energy, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

	state_switcher = not state_switcher


func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	show()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	hide()

