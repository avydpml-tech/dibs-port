extends StaticBody2D

signal interacted

export (String) var signal_id = "boss_door"
export (bool) var is_open = true

onready var origin_modulate = modulate


func _init():
	add_to_group(signal_id)

func _ready():
	if is_open:
		emit_signal("interacted")

func _interacted():
	
	emit_signal("interacted")