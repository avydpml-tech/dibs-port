class_name FadeComponent extends Node

export (NodePath)onready var actor = get_node(actor)
export (bool) var is_on_start_fade = false
export (float) var fade_timer = 0.2

onready var origin_modulate = actor.modulate

var state_switcher: bool = true
var heartbeat_counter: int = 0


func _ready():
	if is_on_start_fade:
		fade()


func fade():
	var new_modulate = Color("00ffffff") if state_switcher else origin_modulate

	var tween = Tween.new()
	add_child(tween)

	tween.interpolate_property(actor, "modulate", actor.modulate, new_modulate, fade_timer, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

	state_switcher = not state_switcher


func fade_heartbeat():
	
	if heartbeat_counter >= 2:
		heartbeat_counter = 0
		return

	var new_modulate = Color("00ffffff") if state_switcher else origin_modulate
	
	var tween = Tween.new()
	add_child(tween)
	
	tween.connect("tween_all_completed", self, "fade_heartbeat")

	tween.interpolate_property(actor, "modulate", actor.modulate, new_modulate, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

	state_switcher = not state_switcher
	heartbeat_counter += 1 if not state_switcher else 0
