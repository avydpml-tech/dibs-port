extends Node2D

func _ready():
	$AnimationPlayer.play("pan_up")
	Globals.get_player().disable_mox()
	_update_stats()


func start_ending():
	EndingsManager.start_ending("elevator")


func _update_stats():
	var updated_text = Achievements.get_stats_string()

	updated_text += "\n\n\n\n\n\n\n\n That's it for this update. \n Thanks for playing!"
	updated_text += "\n\n\n\n\n\n\n\n You can, like, go now."
	updated_text += "\n\n\n\n\n\n\n\n Bye"

	$DiBsLogo / Label2.text = updated_text