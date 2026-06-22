extends Stage

func _ready():
	Globals.get_player().enable_blaster()

func _on_Area2D_body_entered(body):
	if body.get_name() == "playerChar":
		print_debug("Floor: SURPRISE")
		$breakableFloor.call_deferred("set_mode", RigidBody2D.MODE_RIGID)
		$puffSmokes.emitting = true
		$puffSmokes2.emitting = true
		SoundManager.play_bsfx("metal_floor_break", 0, - 4)
