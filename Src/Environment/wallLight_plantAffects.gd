extends StaticBody2D

export (bool) var flicker = false


func _ready():
	add_to_group("CanBeShot")
	if flicker:
		$AnimationPlayer.play("flicker")


onready var flashlight_area2D = $Area2D
var bodies_in_flashlight = []

func _is_flashing_Nonplayer():
	for body in flashlight_area2D.get_overlapping_bodies():
		if body.get_class() == "Nonplayer":
			bodies_in_flashlight.append(body)
			body.flashed_by_flashlight()


func stopped_flashlight():
	for body in bodies_in_flashlight:
		if body != null:
			if get_owner().has_node(body.get_path()):
				body.not_flashed_anymore()
				

	bodies_in_flashlight = []
			
func shot(_dmg = null):
	stopped_flashlight()
	call_deferred("queue_free")
