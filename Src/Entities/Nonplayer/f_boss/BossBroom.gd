extends Node2D

export (NodePath)onready var actor = get_node(actor)

var is_fall: = false

func _ready():
	actor.connect("state_changed", self, "check_fall_broom")
	hide()


func check_fall_broom(state):
	if actor.is_broom_given:
		show()

	if actor.is_boss_fight and not is_fall:
		is_fall = true
		$AnimationPlayer.play("fall")
